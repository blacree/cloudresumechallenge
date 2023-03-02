terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "4.22.0"
        }
    }

    # Remove backend code to use local
    # backend "s3" {
    #   bucket = ""                   # bucket name
    #   encrypt = true
    #   key = ""                      # statefile name
    #   region = "us-east-1"
    # }
}

# Change profile to use another iam profile
provider "aws"{
    region = "us-east-1"
    # profile = "default"
}


# Modules
module "s3_module"{
    source = "./s3_module/"
}

module "cloudfront_module"{
    source = "./cloudfront_module/"
    bucket_regional_domain_name = module.s3_module.bucket_regional_domain_name
}

module "iam_policies_module"{
    source = "./iam_policies_module"
}

module "dynamoDB_module"{
    source = "./dynamoDB_module"
}

module "lambda_function_module"{
    crc_iam_role_arn = module.iam_policies_module.crc_iam_role_arn
    cloudwatch_dynamoDB_streams_iam_role_arn = module.iam_policies_module.cloudwatch_dynamoDB_streams_iam_role_arn
    gateway_method = module.api_gateway_module.gateway_method
    resource_path = module.api_gateway_module.resource_path
    crc_rest_api_execution_arn = module.api_gateway_module.crc_rest_api_execution_arn
    crc_dynamoDB_stream_arn = module.dynamoDB_module.crc_dynamoDB_stream_arn
    source = "./lambda_function_module"
}

module "api_gateway_module"{
    crc_lambda_invoke_arn = module.lambda_function_module.crc_lambda_invoke_arn
    source = "./api_gateway_module"
}


# Outputs
output "crc_cloudfront_Url"{
    value = "https://${module.cloudfront_module.cloudfront_domain}"
}

# output "api_source_arn"{
#     value = module.lambda_function_module.api_source_arn
# }

output "api_gateway_stage_details"{
    value = module.api_gateway_module.api_gateway_stage_details
}

output "crc_s3_url" {
  value = "http://${module.s3_module.s3_website_endpoint}"

  depends_on = [
    module.s3_module
  ]
}
