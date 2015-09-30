# cloudforms-export
This code enables the export of a VM from RHEV to another format.  In this scenario, you might not have your entire hybrid cloud managed by CloudForms and you need to move your VM from RHEV to another virtual infrastructure or cloud.  This automate code…

Once the export is complete, it is presented as an HTTPS download with the URL listed as a Custom Attribute of the exported Virtual Machine.

1. Exports the virtual machine
2. Converts it to an OVA for RHEV, vmdk for VMware, or Qcow2 for OpenStack.
3. Creates a folder in the export storage domain share based on the user name logged into CloudForms
4. Places the exported VM in that folder
5. Deletes the VM from the export storage domain
6. Creates a Custom Attribute containing the HTTPS URL of the exported file.

Note: This requires CFME 5.3 or better.

Note2: You must install qemu-img and glusterfs-fuse packages on your CloudForms appliance

Note3: This code mounts the export storage domain as NFS

###Obtain Automate Code
1. Clone repository
2. Compress the POC folder as a ZIP archive

###Integration
1. Install and configure CloudForms
2. Login
3. Navigate to “Automate” —> Import/Export
4. Click browse
5. Navigate to the zipped archive
6. Upload the archive
7. Navigate to “Automate” —> “Explorer”
8. Ensure the POC domain is enabled
9. Navigate to “Automate” —> “Customization” and the “Buttons” accordionan on the left
10. Create a button group named “Export” under “VM and Instance”
11. Create three buttons
 
 a. “Export for RHEV”  —> System/Process/Request Request—>Export
 
 b. “Export for VMware” —> System/Process/Request Request—>ExportVmdk
 
 c. “Export for OpenStack” —> System/Process/Request Request—>ExportQcow2
12.  Create a symlink from the "public" directory of the CloudForms appliance (/var/www/..../public/exports/) to /mnt/exports/
13.  Set the "export_domain" schema variable to the correct name of your Export Domain.
