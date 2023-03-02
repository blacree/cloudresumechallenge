variable location {}

resource "azurerm_resource_group" "crc_resource_group" {
    name = "crc_resource_group"
    location = var.location
}

output "resource_g_name" {
    value = azurerm_resource_group.crc_resource_group.name
}