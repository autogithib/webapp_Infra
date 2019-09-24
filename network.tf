#creating resource group
resource "azurerm_resource_group" "main" {
    name            = "${var.cluster_name}-resources"
    location        = "${var.cluster_location}"
}


#Create Network Security Group

resource "azurerm_network_security_group" "nsg" {
    name                = "${azurerm_virtual_network.main.name}-nsg"
    location            = "${azurerm_resource_group.main.location}"
    resource_group_name = "${azurerm_resource_group.main.name}"
    security_rule {
        name                       = "ssh"
        priority                   = 900
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "http-8080"
        priority                   = 899
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "staging"
    }
}

#Virtual network
resource "azurerm_virtual_network" "main" {
    name                        = "${var.cluster_name}-vnetwork"
    address_space               =  ["10.0.0.0/16"]
    resource_group_name         = "${azurerm_resource_group.main.name}"
    location                    = "${azurerm_resource_group.main.location}"
}



#Subnet
resource "azurerm_subnet" "internal" {
    name                    = "internal"
    resource_group_name     = "${azurerm_resource_group.main.name}"
    virtual_network_name    = "${azurerm_virtual_network.main.name}"
    address_prefix          = "10.0.2.0/24"
}


resource "azurerm_availability_set" "avset" {
  name                = "avset"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  platform_fault_domain_count  = 1
  platform_update_domain_count = 1
  managed                      = true

  tags = {
    environment = "staging"
  }
}

