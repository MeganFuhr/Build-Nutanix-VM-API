begin{
	Add-PSSnapin nutanixcmdletspssnapin
	$VMName = "VMName"
    
#Certificate information to call Nutanix Prism API
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
    ServicePoint srvPoint, X509Certificate certificate,
    WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# Forcing PoSH to use TLS1.2 as it defaults to 1.0 and Prism requires 1.2.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$cred = Get-Credential
$Header = @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($cred.username+":"+$cred.password ))}
$PrismCentral = "PrismCentral.YourCompany.com"
$BuildCluster = "PrismElement.YourCompany.com"
$NutanixHostingConnection = Get-Content -Path "\\path\to\your\clusters\NTNXCluster.txt"
$allNutanixVMs = @()

#get all nutanix VMS across all the clusters. Create a custom object to include the cluster name
foreach ($connection in $NutanixHostingConnection) {

	$NTNXVMsUri = "https://$($connection):9440/PrismGateway/services/rest/v2.0/vms"

	$NTNXVMs = (Invoke-RestMethod -Method Get -Uri $NTNXVMsUri -Headers $Header).entities

		foreach ($item in $NTNXVMs) {
			$temp = New-Object psobject -Property @{
				VMName = $item.name
				VMUUID = $item.uuid
				HostingConnection = $connection
			   }
			 $allNutanixVMs += $temp
		} 
}

if ($allNutanixVMs.vmname -contains $VMName) {
    Write-Host "$VMName Nutanix object already exists on another cluster."
    $LastExitCode = 1
    exit $LASTEXITCODE
}


$VMCreatePayload = @"
{
	"spec":{
		"name":"$($VMName)",
		"resources":{
"power_state":"OFF",
			"num_vcpus_per_socket":2,
			"num_sockets":2,
      	"memory_size_mib":8192,
      	"hardware_clock_timezone": "America/Boise",    
		"nic_list":[{
			"nic_type":"NORMAL_NIC",
			"is_connected":true,
			"ip_endpoint_list":[{
				"ip_type":"DHCP"
			}],
			"subnet_reference":{
			"kind":"subnet",
			"name":"{{Network Name}}",
			"uuid":"{{Network UUID}}"
			}
			}]		
		},
		"cluster_reference":{
      "uuid": "{{Cluster UUID}}",
      "kind":"cluster" 
		}
	},
	"api_version":"3.1.0",
	"metadata":{
    "kind":"vm",
    "project_reference": {
      "kind": "project",
      "name": "{{Project Name}}",
      "uuid": "{{Project UUID}}"
    },
"use_categories_mapping": true
	}
}
"@

$DiskCreatePayload = @"
{
  "vm_disks": [
    {
      "disk_address": {
        "device_bus": "SCSI",
        "device_index": 0
      },
      "is_cdrom": false,
      "is_empty": true,
      "vm_disk_create": {
        "size": 64424509440,
        "storage_container_uuid": "{{Storage Container UUID}}"
      }
    },
    {
        "disk_address": {
          "device_bus": "IDE",
          "device_index": 0
		},
		"is_cdrom": true,
		"vm_disk_clone": {
			"disk_address": {
			  "device_bus": "IDE",
			  "device_index": 0,
			  "vmdisk_uuid": "{{ISO UUID}}"
			}
		}
	}
  ]
}
"@

}
Process {
	#Create VM via Prism Central v3 API
    $PrismCentralURI = "https://$($PrismCentral):9440/api/nutanix/v3/vms"
	$Response = Invoke-RestMethod -Method POST -Uri $PrismCentralURI -Headers $Header -ContentType 'application/json' -Body $VMCreatePayload

Start-Sleep -seconds 10

	#Create and attach disks using Prism Element v2 API
	$PrismElementURI = "https://$($BuildCluster):9440/PrismGateway/services/rest/v2.0/vms/$($response.metadata.uuid)/disks/attach"
	#$Response = Invoke-RestMethod -Method POST -Uri $PrismElementURI -Headers $Header -ContentType 'application/json' -Body $DiskCreatePayload	
	$DiskResponse = Invoke-RestMethod -Method POST -Uri $PrismElementURI -Headers $Header -ContentType 'application/json' -Body $DiskCreatePayload
}

end {
#Nothing here needed
}