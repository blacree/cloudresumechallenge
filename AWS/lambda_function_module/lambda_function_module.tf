# Lambda inputs (VARS)
variable "gateway_method" {}
variable "resource_path" {}
variable "crc_iam_role_arn" {}
variable "cloudwatch_dynamoDB_streams_iam_role_arn" {}
variable "crc_dynamoDB_stream_arn" {}
variable crc_rest_api_execution_arn {}


# Resources
# Note: Always make and push changes to your lambda code through terraform. The source_code_hash is used to detect differences in the code of your infrastructure and local.
# So any recent changes made in your infrasturcture would be overwritten by that of your local even if it is more recent.

# Lambda function for the API gateway
resource "aws_lambda_function" "crc_lambda_function"{
    function_name = "crc_lambda_function"
    filename = "./lambda_function_module/lambda_function_docs/lambda_f.zip"
    role = var.crc_iam_role_arn
    handler = "crc_lambda_function.lambda_handler"
    runtime = "python3.9"
    source_code_hash = filemd5("./lambda_function_module/lambda_function_docs/lambda_f.zip")

    tags = {
        "Description" = "crc lambda function. Terraform provisioned"
    }
}

# crc lambda api-gateway permission
resource "aws_lambda_permission" "crc_lambda_permission" {
    statement_id = "AllowLambdaExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.crc_lambda_function.function_name
    principal = "apigateway.amazonaws.com"
    source_arn =  "${var.crc_rest_api_execution_arn}/*/${var.gateway_method}${var.resource_path}"
}


# Lambda function for monitoring crc dynamoDB streams
resource "aws_lambda_function" "crc_dynamodDB_streams"{
    function_name = "monitor_crc_dynamoDB_streams"
    filename = "./lambda_function_module/lambda_function_docs/lambda_f_dynamodb.zip"
    role = var.cloudwatch_dynamoDB_streams_iam_role_arn
    handler = "monitor_crc_dynamoDB_streams.lambda_handler"
    runtime = "python3.9"
    source_code_hash = filemd5("./lambda_function_module/lambda_function_docs/lambda_f_dynamodb.zip")

    tags = {
        "Description" = "Montor changes to crc dynamoDB table"
    }
}

# Access crc dynamodb database
resource "aws_lambda_event_source_mapping" "access_crc_dynamodb_stream_evnets" {
  event_source_arn  = var.crc_dynamoDB_stream_arn
  function_name     = aws_lambda_function.crc_dynamodDB_streams.function_name
  starting_position = "LATEST"
  batch_size = 1
}


# Outputs
output "crc_lambda_invoke_arn"{
    value = aws_lambda_function.crc_lambda_function.invoke_arn
}

# output "api_source_arn"{
#     value = aws_lambda_permission.crc_lambda_permission.source_arn
# }