resource "azurerm_storage_account" "zero-sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.zero-rg.name
  location                 = azurerm_resource_group.zero-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  # public_network_access_enabled = true. if not, 404 error will occur.
  public_network_access_enabled = true
}

resource "azurerm_storage_container" "zero-cont" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.zero-sa.name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.zero-sa
  ]
}

# Updload the IIS configuration script as a blob to the Azure Storage Account 
# resource "azurerm_storage_blob" "zero-blob" {
#   name                   = "IIS_Config.ps1"
#   storage_account_name   = var.storage_account_name
#   storage_container_name = azurerm_storage_container.zero-cont.name
#   type                   = "Block"
#   source                 = "IIS_Config.ps1"
#   depends_on = [
#     azurerm_storage_container.zero-cont
#   ]
# }

resource "azurerm_storage_blob" "IIS_config_video" {
  name                   = "IIS_Config_video.ps1"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.zero-cont.name
  type                   = "Block"
  source                 = "IIS_Config_video.ps1"
  depends_on = [
    azurerm_storage_container.zero-cont
  ]
}

resource "azurerm_storage_blob" "IIS_config_image" {
  name                   = "IIS_Config_image.ps1"
  storage_account_name   = var.storage_account_name
  storage_container_name = azurerm_storage_container.zero-cont.name
  type                   = "Block"
  source                 = "IIS_Config_image.ps1"
  depends_on = [
    azurerm_storage_container.zero-cont
  ]
}