terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.45.0"
    }
  }

  # backend "azurerm" {
  #   resource_group_name = ""
  #   storage_account_name = ""
  #   container_name = ""
  #   key = ""
  #   subscription_id = ""
  #   tenant_id = ""
  # }
}

provider "azurerm" {
  features {}
  subscription_id = ""
}

locals {
  location = "East US"
}

module "resource_group_module"{
  source = "./resource_group_module"
  location = local.location
}

module "storage_module"{
  source = "./storage_module"
  location = local.location
  resource_group_name = module.resource_group_module.resource_g_name

  depends_on = [
    module.resource_group_module
  ]
}

module "cosmodb_module"{
  source = "./cosmodb_module"
  location = local.location
  resource_group_name = module.resource_group_module.resource_g_name

  depends_on = [
    module.resource_group_module
  ]
}

module "app_insights_module"{
  source = "./app_insights_module"
  location = local.location
  resource_group_name = module.resource_group_module.resource_g_name

  depends_on = [
    module.resource_group_module
  ]
}

module "function_module"{
  source = "./function_module"
  location = local.location
  resource_group_name = module.resource_group_module.resource_g_name
  storage_account_name = module.storage_module.storage_account_name
  storage_access_key = module.storage_module.storage_access_key
  storage_account_id = module.storage_module.storage_account_id
  zip_file_hash = module.storage_module.zip_file_hash
  function_code_zip_file_url = module.storage_module.function_code_zip_file_url
  database_account_name = module.cosmodb_module.db_account_name
  database_endpoint = module.cosmodb_module.db_endpoint
  database_primary_key = module.cosmodb_module.db_primary_key
  app_insights_key = module.app_insights_module.instrumentation_key
  app_insights_connection_string = module.app_insights_module.app_insights_connection_string

  depends_on = [
    module.storage_module,
    module.cosmodb_module,
    module.app_insights_module
  ]
}


output "crc_site_url"{
  value = "https://${module.storage_module.storage_account_name}.blob.core.windows.net/${module.storage_module.container_name}/index.html"
}

output "function_code_uploaded"{
  value = "[*] Your function code saved @ ${module.storage_module.function_code_zip_file_url}"
}

output "Note"{
  value = "Make sure to update the api url saved in your index.js file to the right function url"
}