terraform{
    required_version = ">= 0.13"

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 2.26"
        }
    }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "groupmjraula02" {
  name = "groupmjraula02"
  location = "eastus"
}

resource "azurerm_virtual_network" "networkmjraula02" {
    name                = "networkmjraula02"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.groupmjraula02.name
}

resource "azurerm_subnet" "subnetmjraula02"{
    name = "subnetmjraula02"
    resource_group_name  = azurerm_resource_group.groupmjraula02.name
    virtual_network_name = azurerm_virtual_network.networkmjraula02.name
    address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "publicIpmjraula02" {
    name                         = "publicIpmjraula02"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.groupmjraula02.name
    allocation_method            = "Static"
}

resource "azurerm_network_security_group" "nsgmjraula02" {
    name                = "nsgmjraula02"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.groupmjraula02.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "MySQL"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface" "nicmjraula02" {
    name                      = "nicmjraula02"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.groupmjraula02.name

    ip_configuration {
        name                          = "nicConfigurationMjrAula02"
        subnet_id                     = azurerm_subnet.subnetmjraula02.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicIpmjraula02.id
    }
}

resource "azurerm_network_interface_security_group_association" "nicandsecassociation" {
    network_interface_id      = azurerm_network_interface.nicmjraula02.id
    network_security_group_id = azurerm_network_security_group.nsgmjraula02.id
}

resource "azurerm_storage_account" "storageaccountmjraula02" {
    name                        = "storageaccountmjraula02"
    resource_group_name         = azurerm_resource_group.groupmjraula02.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

resource "tls_private_key" "sshmjraula02" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tlsprivatekey" { 
  value = tls_private_key.sshmjraula02.private_key_pem 
}

resource "azurerm_linux_virtual_machine" "vmmjraula02" {
    name                  = "vmmjraula02"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.groupmjraula02.name
    network_interface_ids = [azurerm_network_interface.nicmjraula02.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "osDiskmjraula02"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "vmMjrAula02"
    admin_username = "azureuser"
    admin_password = "AticaticaXURU#!@pwd123"
    disable_password_authentication = false

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.sshmjraula02.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storageaccountmjraula02.primary_blob_endpoint
    }

    depends_on = [ azurerm_resource_group.groupmjraula02 ]
}

output "public_ip_address" {
  value = azurerm_public_ip.publicIpmjraula02.ip_address
}

#workaround-pro
resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_linux_virtual_machine.vmmjraula02]
  create_duration = "30s"
}

#Instalar o MySQL
resource "null_resource" "deployMySQL" {
    triggers = {
        order = time_sleep.wait_30_seconds.id
    }
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = azurerm_linux_virtual_machine.vmmjraula02.admin_username
            password = azurerm_linux_virtual_machine.vmmjraula02.admin_password
            host = azurerm_public_ip.publicIpmjraula02.ip_address
        }
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y mysql-server"
        ]
    }
}