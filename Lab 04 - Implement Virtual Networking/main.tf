# Lab 04 - Implement Virtual Networking

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "az104-04-rg1"
  location = "eastus"
}

module "linuxservers" {
  source              = "./Modules/LinuxUbuntu"
  resource_group_name = azurerm_resource_group.example.name
  vm_os_simple        = "UbuntuServer"
  #public_ip_dns       = ["linsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id = module.network.vnet_subnets[0]

  depends_on = [azurerm_resource_group.example]
}

module "linuxservers_2" {
  source              = "./Modules/LinuxUbuntu_2"
  resource_group_name = azurerm_resource_group.example.name
  vm_os_simple        = "UbuntuServer"
  #public_ip_dns       = ["linsimplevmips"] // change to a unique name per datacenter region
  vnet_subnet_id = module.network.vnet_subnets[1]

  depends_on = [azurerm_resource_group.example]
}

module "network" {
  source              = "./Modules/Network"
  resource_group_name = azurerm_resource_group.example.name
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
  subnet_names        = ["subnet1", "subnet2"]

  depends_on = [azurerm_resource_group.example]
}