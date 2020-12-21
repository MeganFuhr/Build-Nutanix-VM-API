# Build-Nutanix-VM-API

This PowerShell script leverages the Prism Element v2 API and the Prism Central v3 API to create a virtual machine with the following configuration:  
8 GB RAM<br/>
2 vCPUS per socket<br/>
2 sockets<br/>
60 GB SCSI drive<br/>
CD ROM with ISO attached<br/>
America/Bois timezone<br/>
Defined network<br/>
Define cluster<br/>
Define Project<br/>
<br/>
Through research and a confirmation from Nutanix support, you still require Prism Element and v2 to create and attach disks IF you want them on a specific container.  
The virtual machine is created and then the disks are created/attached.  I posted this complete script in hopes to help someone else trying to work their way through 
the API documentation.<br/><br/>

In order to use in your environment, you will need to adjust the following items:<br/>
$VMName<br/>
$PrismCentral<br/>
$BuildCluster (Prism Element cluster)<br/>
$cred (Supply credentials, Nutanix require UPN)<br/>
$NutanixHostingConnection (If all your clusters are not in Prism Central AND you want to ensure two objects are not named the same)<br/><br/>

In the JSON:<br/>
Network Name<br/>
Network UUID<br/>
Cluster UUID<br/>
Project Name (Optional to remove)<br/>
Project UUID (Optional to remove)<br/>
"size" (This is in bytes.  60 GB = 64424509440<br/>
Storage Container UUID<br/>
ISO UUID<br/>

