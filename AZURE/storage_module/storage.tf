variable location {}
variable "resource_group_name" {}
variable "path_to_function_code"{
    default = "function_module/function_code_files/"
}

module dir {
    source = "hashicorp/dir/template"
    version = "1.0.2"
    base_dir = "${path.module}/website/"
}

resource "azurerm_storage_account" "crc_storage_account" {
    name = "crcstorage2023"
    resource_group_name = var.resource_group_name
    location = var.location
    account_tier = "Standard"
    account_replication_type = "LRS"

    tags = {
      Name = "cloud-resume-challenge"
    }
}

resource "azurerm_storage_container" "crc_container" {
    name = "crc-container"
    storage_account_name = azurerm_storage_account.crc_storage_account.name
    container_access_type = "blob"
}

resource "azurerm_storage_blob" "upload_web_files" {
    for_each = module.dir.files
    name = each.key
    content_type = each.value.content_type
    source = each.value.source_path
    content_md5 = each.value.digests.md5
    type = "Block"
    storage_account_name = azurerm_storage_account.crc_storage_account.name
    storage_container_name = azurerm_storage_container.crc_container.name
}

resource "azurerm_storage_container" "function_code_container"{
    name = "function-code-container"
    storage_account_name = azurerm_storage_account.crc_storage_account.name
    container_access_type = "blob"
}

## If you are using local deployment with WEBSITE_RUN_FROM_PACKAGE URL option
# resource "null_resource" "install_code_dependencies" {
#     triggers = {
#         requirments_md5 = "${filemd5("${var.path_to_function_code}crc_function/requirements.txt")}"
#     }
#     provisioner "local-exec"{
#         command = "pip install --target='${var.path_to_function_code}crc_function/.python_packages/lib/site-packages' -r ${var.path_to_function_code}crc_function/requirements.txt"
#     }

#     depends_on = [
#       azurerm_storage_container.function_code_container
#     ]
# }

data "archive_file" "function_dir"{
    type = "zip"
    source_dir = "${var.path_to_function_code}crc_function/"
    output_path = "${var.path_to_function_code}/function_code.zip"

    depends_on = [
      azurerm_storage_container.function_code_container
    ]

    # depends_on = [
    #     null_resource.install_code_dependencies
    # ]
}


resource "azurerm_storage_blob" "upload_function_code" {
    name =   "crc-function-code-${substr(data.archive_file.function_dir.output_md5, 0, 6)}.zip"
    storage_account_name = azurerm_storage_account.crc_storage_account.name
    storage_container_name = azurerm_storage_container.function_code_container.name
    type = "Block"
    content_md5 = data.archive_file.function_dir.output_md5
    source = "${var.path_to_function_code}/function_code.zip"
    content_type = "application/octet-stream"

    depends_on = [
      data.archive_file.function_dir
    ]
}


output "storage_account_name" {
    value = azurerm_storage_account.crc_storage_account.name
}

output "storage_access_key" {
    value = azurerm_storage_account.crc_storage_account.primary_access_key
}

output "storage_account_id" {
    value = azurerm_storage_account.crc_storage_account.id
}

output "container_name"{
    value = azurerm_storage_container.crc_container.name
}

output "function_code_zip_file_url" {
    value = azurerm_storage_blob.upload_function_code.url
}

output "zip_file_hash"{
    value = data.archive_file.function_dir.output_md5
}