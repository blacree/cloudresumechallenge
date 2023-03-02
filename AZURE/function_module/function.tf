variable location {}
variable "resource_group_name" {}
variable "storage_account_name" {}
variable "storage_access_key" {}
variable "storage_account_id" {}
variable "database_account_name" {}
variable "database_endpoint" {}
variable "database_primary_key" {}
variable "app_insights_key" {}
variable function_code_zip_file_url {}
variable "zip_file_hash" {}
variable "app_insights_connection_string" {}

# variable "storage_account_id" {}

resource "azurerm_service_plan" "function_app_service_plan" {
    name = "ASP-CRC-Function"
    resource_group_name = var.resource_group_name
    location = var.location
    os_type = "Linux"
    sku_name = "Y1"
}

resource "azurerm_linux_function_app" "crc_function_app" {
    name = "crc-function-app"
    resource_group_name = var.resource_group_name
    location = var.location
    storage_account_name = var.storage_account_name
    storage_account_access_key = var.storage_access_key
    service_plan_id = azurerm_service_plan.function_app_service_plan.id
    functions_extension_version = "~4"

    app_settings = {
      "CRC_COSMODB_CS" = "DefaultEndpointsProtocol=https;AccountName=${var.database_account_name};AccountKey=${var.database_primary_key};TableEndpoint=https://${var.database_account_name}.table.cosmos.azure.com:443/;"
      "FUNCTIONS_WORKER_RUNTIME" = "python"
      "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    #   "ENABLE_ORYX_BUILD" = "true"
    #   "WEBSITE_RUN_FROM_PACKAGE" = var.function_code_zip_file_url
    }

    site_config {
        app_scale_limit = 200
        application_insights_key = var.app_insights_key
        application_insights_connection_string = var.app_insights_connection_string
        
        application_stack {
            python_version = "3.10"
        }
    }
}

resource "null_resource" "remote_deployment" {
    triggers = {
        requirments_md5 = var.zip_file_hash
    }
    provisioner "local-exec"{
        command = "az functionapp deployment source config-zip --resource-group ${var.resource_group_name} --name ${azurerm_linux_function_app.crc_function_app.name} --src ./function_module/function_code_files/function_code.zip --build-remote true --verbose"
    }

    depends_on = [
      azurerm_linux_function_app.crc_function_app
    ]
}


# resource "azurerm_role_assignment" "function-code-role" {
#     # name = "crc-storage-role"
#     scope = var.storage_account_id
#     role_definition_name = "Storage Blob Data Reader"
#     principal_id = azurerm_linux_function_app.crc_function_app.identity[0]
# }