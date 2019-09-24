#Create Public IP for master node
resource "azurerm_public_ip" "instances" {
    count                        = length(var.instances)
    name                         = "pubip-${var.instances[count.index]}"
    domain_name_label            = "${var.instances[count.index]}-fqdn"
    location                     = "${azurerm_resource_group.main.location}"
    resource_group_name          = "${azurerm_resource_group.main.name}"
    allocation_method            = "Dynamic"
    tags = {
        environment = "Staging"
    }
}

resource "azurerm_network_interface" "instances" {
  count                     = length(var.instances)
  name                      = "${var.instances[count.index]}-nic"
  location                  = "${azurerm_resource_group.main.location}"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  network_security_group_id   = "${azurerm_network_security_group.nsg.id}"
  ip_configuration  {
    name                          = "ipconfig-${var.instances[count.index]}"
    subnet_id                     = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "Dynamic"   
    public_ip_address_id          = "${element(azurerm_public_ip.instances.*.id, count.index )}"
  }
}


 ############virtual machines ##########################################
resource "azurerm_virtual_machine" "instances" {
  count                 = length(var.instances)
  name                  = var.instances[count.index]
  location              = "${azurerm_resource_group.main.location}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  network_interface_ids = ["${element(azurerm_network_interface.instances.*.id, count.index)}"]
  vm_size               = "Standard_DS1_v2"
  
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = "mastervmfqdn.southeastasia.cloudapp.azure.com"
      user = var.admin_username
      port = var.admin_password
    }
    inline = [
       "ansible -m ping all",
    ]
  }
 
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
   publisher = "OpenLogic"
   offer     = "CentOS"
   sku       = "7.5"
   version   = "latest"
  }
  
  storage_os_disk {
    name              = "${var.instances[count.index]}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

 os_profile {
    computer_name  = var.instances[count.index]
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
    #ssh_keys {
    #  key_data = file("sshkeys/id_rsa.pub")
    #  path     = "/home/${var.admin_username}/.ssh/authorized_keys"
    #}
  }
  tags = {
    environment = "staging"
  }
}

output instances {
  value = ["${azurerm_virtual_machine.instances.*.name}","${azurerm_public_ip.instances.*.ip_address}","${azurerm_public_ip.instances.*.fqdn}"]
}


