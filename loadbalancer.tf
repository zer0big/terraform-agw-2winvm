resource "azurerm_public_ip" "zero-lbfe_pip" {
  name                = "frontend-pip"
  resource_group_name = azurerm_resource_group.zero-rg.name
  location            = azurerm_resource_group.zero-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "zero-lb" {
  name                = "WEB-LoadBalancer"
  location            = azurerm_resource_group.zero-rg.location
  resource_group_name = azurerm_resource_group.zero-rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LB-FrontEnd-IP"
    public_ip_address_id = azurerm_public_ip.zero-lbfe_pip.id
  }

  depends_on = [
    azurerm_public_ip.zero-lbfe_pip
  ]
}

resource "azurerm_lb_backend_address_pool" "zero-bepool" {
  loadbalancer_id = azurerm_lb.zero-lb.id
  name            = "WEBBackEndAddressPool"

  depends_on = [
    azurerm_lb.zero-lb
  ]
}

# data "azurerm_virtual_network" "data-vnet" {
#   name                = var.virtual_network
#   resource_group_name = var.resource_group_name
# }

# data "azurerm_lb" "data-lb" {
#   name                = "WEB-LoadBalancer"
#   resource_group_name = var.resource_group_name
# }

# data "azurerm_lb_backend_address_pool" "data-bepool" {
#   name            = "WEBBackEndAddressPool"
#   loadbalancer_id = data.azurerm_lb.data-lb.id
# }

resource "azurerm_lb_backend_address_pool_address" "web-win-vm1_address" {
  name                    = "web-win-vm1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.zero-bepool.id
  virtual_network_id      = azurerm_virtual_network.zero-vnet.id
  ip_address              = azurerm_network_interface.zero-nic1.private_ip_address
}

resource "azurerm_lb_backend_address_pool_address" "web-win-vm2_address" {
  name                    = "web-win-vm2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.zero-bepool.id
  virtual_network_id      = azurerm_virtual_network.zero-vnet.id
  ip_address              = azurerm_network_interface.zero-nic2.private_ip_address
}

resource "azurerm_lb_probe" "zero-lb-probe" {
  loadbalancer_id = azurerm_lb.zero-lb.id
  name            = "Prove-web"
  port            = 80
  depends_on = [
    azurerm_lb.zero-lb
  ]
}

resource "azurerm_lb_rule" "zero-lb-rule" {
  loadbalancer_id                = azurerm_lb.zero-lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LB-FrontEnd-IP"
  backend_address_pool_ids       = [ azurerm_lb_backend_address_pool.zero-bepool.id ]
  probe_id                       = azurerm_lb_probe.zero-lb-probe.id
  depends_on = [
    azurerm_lb.zero-lb,
    azurerm_lb_probe.zero-lb-probe
  ]
}