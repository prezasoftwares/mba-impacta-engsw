terraform{
    required_version = ">= 0.13"

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 2.26"
        }
    }
}

#Provedor de configurações
provider "azurerm" {
  skip_provider_registration = true
  features {}
}

#Grupo de recursos (agrupador de componentes no Azure)
resource "azurerm_resource_group" "groupmjraula02" {
  name = "groupmjraula02"
  location = "eastus"
}

#Rede virtual
resource "azurerm_virtual_network" "networkmjraula02" {
    name                = "networkmjraula02"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.groupmjraula02.name
}

#Sub rede virtual
resource "azurerm_subnet" "subnetmjraula02"{
    name = "subnetmjraula02"
    resource_group_name  = azurerm_resource_group.groupmjraula02.name
    virtual_network_name = azurerm_virtual_network.networkmjraula02.name
    address_prefixes       = ["10.0.1.0/24"]
}

#IP Publico da maquina
resource "azurerm_public_ip" "publicIpmjraula02" {
    name                         = "publicIpmjraula02"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.groupmjraula02.name
    allocation_method            = "Static"
}

#NSG - Firewall - regras de entrada e saída da rede
resource "azurerm_network_security_group" "nsgmjraula02" {
    name                = "nsgmjraula02"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.groupmjraula02.name

    #Abre a porta para o SSH
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

    #Abre a porta pro MySQL - a porta do arquivo de Config do MySQL tem que ser igual a porta de entrada configurada aqui (3306)
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

#Placa de rede
resource "azurerm_network_interface" "nicmjraula02" {
    name                      = "nicmjraula02"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.groupmjraula02.name

    #atribuição de IP (publico)
    ip_configuration {
        name                          = "nicConfigurationMjrAula02"
        subnet_id                     = azurerm_subnet.subnetmjraula02.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicIpmjraula02.id
    }
}

#associar a NSG (Firewall) com a interface de rede (placa de rede)
resource "azurerm_network_interface_security_group_association" "nicandsecassociation" {
    network_interface_id      = azurerm_network_interface.nicmjraula02.id
    network_security_group_id = azurerm_network_security_group.nsgmjraula02.id
}

#conta de armazenamento (para disco virtual e outras configs do Azure)
resource "azurerm_storage_account" "storageaccountmjraula02" {
    name                        = "storageaccountmjraula02"
    resource_group_name         = azurerm_resource_group.groupmjraula02.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

#maquina virtual com as configs necessárias (dependencias implicitas dos itens acima)
resource "azurerm_linux_virtual_machine" "vmmjraula02" {
    name                  = "vmmjraula02"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.groupmjraula02.name
    network_interface_ids = [azurerm_network_interface.nicmjraula02.id]
    size                  = "Standard_DS1_v2"

    #disco virtual da vm
    os_disk {
        name              = "osDiskmjraula02"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    #Imagem do Linux pra subir na VM
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    #Nome da VM e credenciais
    computer_name  = "vmMjrAula02"
    admin_username = "azureuser"
    admin_password = "AticaticaXURU#!@pwd123"
    disable_password_authentication = false

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storageaccountmjraula02.primary_blob_endpoint
    }

    depends_on = [ azurerm_resource_group.groupmjraula02 ]
}

#ip public da maquina (saída) - obter no console e utilizar na conexão via SSH ou MySQL driver
output "public_ip_address" {
  value = azurerm_public_ip.publicIpmjraula02.ip_address
}


#workaround-pro (dá um tempo pra máquina respirar)
resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_linux_virtual_machine.vmmjraula02]
  create_duration = "30s"
}

#upload do arquivo de script e config para subir a instancia do MySQL
resource "null_resource" "upload_dbcfgfiles" {
    provisioner "file" {
        connection {
            type = "ssh"
            user = azurerm_linux_virtual_machine.vmmjraula02.admin_username
            password = azurerm_linux_virtual_machine.vmmjraula02.admin_password
            host = azurerm_public_ip.publicIpmjraula02.ip_address
        }
        source = "config"
        destination = "/home/azureuser"
    }

    depends_on = [ time_sleep.wait_30_seconds ]
}


#Instalar o MySQL
resource "null_resource" "deployMySQL" {
    triggers = {
        order = null_resource.upload_dbcfgfiles.id
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
            "sudo apt-get install -y mysql-server",
            "sudo mysql < /home/azureuser/config/user.sql",
            "sudo cp -f /home/azureuser/config/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf",
            "sudo service mysql restart",
            "sleep 30"
        ]
    }
}
