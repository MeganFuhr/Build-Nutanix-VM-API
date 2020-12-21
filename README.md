# Build-Nutanix-VM-API

This PowerShell script leverages the Prism Element v2 API and the Prism Central v3 API to create a virtual machine with the following configuration:
8 GB RAM
2 vCPUS per socket
2 sockets
60 GB SCSI drive
CD ROM with ISO attached
America/Bois timezone
Defined network
Define cluster
Define Project

Through research and a confirmation from Nutanix support, you still require Prism Element and v2 to create and attach disks IF you want them on a specific container.  
The virtual machine is created and then the disks are created/attached.  I posted this complete script in hopes to help someone else trying to work their way through 
the API documentation.

In order to use in your environment, you will need to adjust the following items:
$VMName
$cred (Supply credentials, Nutanix require UPN)
$NutanixHostingConnection (If all your clusters are not in Prism Central AND you want to ensure two objects are not named the same)

In the JSON:
{{Network Name}}
{{Network UUID}}
{{Cluster UUID}}
{{Project Name}} (Optional to remove)
{{Project UUID}} (Optional to remove)
"size" (This is in bytes.  60 GB = 64424509440
{{Storage Container UUID}}
{{ISO UUID}}
