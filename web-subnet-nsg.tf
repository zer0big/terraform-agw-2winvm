resource "azurerm_subnet" "web-subnet" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.zero-rg.name
  virtual_network_name = azurerm_virtual_network.zero-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.zero-vnet
  ]
}

resource "azurerm_subnet" "agw-subnet" {
  name                 = "agw-subnet"
  resource_group_name  = azurerm_resource_group.zero-rg.name
  virtual_network_name = azurerm_virtual_network.zero-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_virtual_network.zero-vnet
  ]
}

resource "azurerm_network_security_group" "zero-nsg" {
  name                = "webvm-nsg"
  location            = azurerm_resource_group.zero-rg.location
  resource_group_name = azurerm_resource_group.zero-rg.name
}

resource "azurerm_network_security_rule" "zero-nsg_rule" {
  for_each                    = local.app_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.zero-rg.name
  network_security_group_name = azurerm_network_security_group.zero-nsg.name
  depends_on = [
    azurerm_network_security_group.zero-nsg
  ]
}

resource "azurerm_subnet_network_security_group_association" "zero-nsg_association" {
  subnet_id                 = azurerm_subnet.web-subnet.id
  network_security_group_id = azurerm_network_security_group.zero-nsg.id
}