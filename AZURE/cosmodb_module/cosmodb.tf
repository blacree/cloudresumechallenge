variable location {}
variable "resource_group_name" {}


resource "azurerm_cosmosdb_account" "crc_table_database"{
    name = "crc-cosmosdb-2023"
    location = var.location
    resource_group_name = var.resource_group_name
    offer_type = "Standard"
    kind = "GlobalDocumentDB"

    enable_automatic_failover = false

    capabilities {
      name = "EnableTable"
    }
    capabilities {
      name = "EnableServerless"
    }
    consistency_policy {
      consistency_level = "BoundedStaleness"
      max_interval_in_seconds = 86400
      max_staleness_prefix = 1000000
    }
    backup {
      type = "Continuous"
    }

    geo_location {
        location = var.location
        failover_priority = 0
    }
}

output "db_account_name" {
    value = azurerm_cosmosdb_account.crc_table_database.name
}

output "db_endpoint"{
    value = azurerm_cosmosdb_account.crc_table_database.endpoint
}

output "db_primary_key" {
    value = azurerm_cosmosdb_account.crc_table_database.primary_key
}