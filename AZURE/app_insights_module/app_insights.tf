variable location {}
variable "resource_group_name" {}

resource "azurerm_application_insights" "crc_app_insights" {
    name = "crc-app-insights"
    location = var.location
    resource_group_name = var.resource_group_name
    application_type = "web"
}

output "instrumentation_key"{
    value = azurerm_application_insights.crc_app_insights.instrumentation_key
}

output "app_insights_connection_string"{
    value = azurerm_application_insights.crc_app_insights.connection_string
}