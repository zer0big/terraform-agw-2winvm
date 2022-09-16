data "azurerm_client_config" "current" {}

# Pull existing Key Vault from Azure
data "azurerm_key_vault" "zero-kv" {
  name                = var.keyvault_name
  resource_group_name = local.resource_group_name
}

data "azurerm_key_vault_secret" "kv_secret_web" {
  name         = var.keyvault_secretname_web
  key_vault_id = data.azurerm_key_vault.zero-kv.id
}

data "azurerm_key_vault_secret" "kv_secret_db" {
  name         = var.keyvault_secretname_db
  key_vault_id = data.azurerm_key_vault.zero-kv.id
}