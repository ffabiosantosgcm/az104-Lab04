#Azure Generic vNet Module
data "azurerm_resource_group" "LinuxUbuntu_2" {
  name = var.resource_group_name
}


# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip_2" {
  name                = "az104-04-pip1"
  location            = "eastus"
  resource_group_name = data.azurerm_resource_group.LinuxUbuntu_2.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Terraform Demo"
  }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic_2" {
  name                = "az104-04-nic1"
  location            = "eastus"
  resource_group_name = data.azurerm_resource_group.LinuxUbuntu_2.name
  ip_configuration {
    name                          = "myNicConfiguration_2"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip_2.id
  }

  tags = {
    environment = "Terraform Demo"
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm_2" {
  name                  = "az104-04-vm1"
  location              = "eastus"
  resource_group_name = data.azurerm_resource_group.LinuxUbuntu_2.name
  network_interface_ids = [azurerm_network_interface.myterraformnic_2.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "az104-04-vm01_OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "az104-04-vm1"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }
  
  tags = {
    environment = "Terraform Demo"
  }
}