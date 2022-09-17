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

resource "azurerm_public_ip" "zero-agw_pip" {
  name                = "agw-pip"
  resource_group_name = azurerm_resource_group.zero-rg.name
  location            = azurerm_resource_group.zero-rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "zero-appgw" {
  name                = "appgateway"
  resource_group_name = azurerm_resource_group.zero-rg.name
  location            = azurerm_resource_group.zero-rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "zero-gateway-ip-configuration"
    subnet_id = azurerm_subnet.agw-subnet.id
  }

  frontend_port {
    name = "frontend_port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend_ip_configuration"
    public_ip_address_id = azurerm_public_ip.zero-agw_pip.id
  }

  backend_address_pool {
    name = "videopool"
    ip_addresses = [ 
      "${azurerm_network_interface.zero-nic1.private_ip_address}" ]
  }

  backend_address_pool {
    name = "imagepool"
    ip_addresses = [ 
      "${azurerm_network_interface.zero-nic2.private_ip_address}" ]
  }

  backend_http_settings {
    name                  = "http-setting"
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "frontend_ip_configuration"
    frontend_port_name             = "frontend_port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name               = "RoutingRule"
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "RoutingPath"
    http_listener_name = "listener"
  }

  url_path_map {
    name                               = "RoutingPath"    
    default_backend_address_pool_name   = "videopool"
    default_backend_http_settings_name  = "http-setting"

    path_rule {
      name                          = "VideoRoutingRule"
      backend_address_pool_name     = "videopool"
      backend_http_settings_name    = "http-setting"
      paths = [
        "/videos/*",
      ]
    }

    path_rule {
      name                          = "ImageRoutingRule"
      backend_address_pool_name     = "imagepool"
      backend_http_settings_name    = "http-setting"
      paths = [
        "/images/*",
      ]
    }
  }
}