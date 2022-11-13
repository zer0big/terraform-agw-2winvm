resource "azurerm_resource_group" "zero-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "zero-vnet" {
  name                = "zero-vnet"
  location            = azurerm_resource_group.zero-rg.location
  resource_group_name = azurerm_resource_group.zero-rg.name
  address_space       = ["10.0.0.0/16"]
  depends_on = [
    azurerm_resource_group.zero-rg
  ]
}

resource "azurerm_availability_set" "zero-as" {
  name                         = "webvm-as"
  location                     = azurerm_resource_group.zero-rg.location
  resource_group_name          = azurerm_resource_group.zero-rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  depends_on = [
    azurerm_resource_group.zero-rg
  ]
}