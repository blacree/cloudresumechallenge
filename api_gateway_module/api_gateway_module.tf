# VARS
variable "crc_lambda_invoke_arn" {}


# Resources
resource "aws_api_gateway_rest_api" "crc_rest_api"{
    name = "crc_rest_api"
    description = "crc api gateway - Terraform provisioned"
}

resource "aws_api_gateway_resource" "getcounter" {
    parent_id = aws_api_gateway_rest_api.crc_rest_api.root_resource_id
    path_part = "getcounter"
    rest_api_id = aws_api_gateway_rest_api.crc_rest_api.id
}

resource "aws_api_gateway_method" "get_method" {
    authorization = "NONE"
    http_method = "GET"
    resource_id = aws_api_gateway_resource.getcounter.id
    rest_api_id = aws_api_gateway_rest_api.crc_rest_api.id
}

resource "aws_api_gateway_integration" "crc_lambda_integration" {
    rest_api_id = aws_api_gateway_rest_api.crc_rest_api.id
    resource_id = aws_api_gateway_resource.getcounter.id
    http_method = aws_api_gateway_method.get_method.http_method
    type = "AWS_PROXY"
    # Note "POST" integration_http_method is necessary as lambda can only be invoked through the POST method
    integration_http_method = "POST"
    uri = var.crc_lambda_invoke_arn
}

resource "aws_api_gateway_integration_response" "crc_api_gateway_integration_response"{
    rest_api_id = aws_api_gateway_rest_api.crc_rest_api.id
    resource_id = aws_api_gateway_resource.getcounter.id
    http_method = aws_api_gateway_method.get_method.http_method
    status_code = aws_api_gateway_method_response.gateway_method_response.status_code
    # response_templates = {
    #     "application/json":""
    # }

    depends_on = [
      aws_api_gateway_integration.crc_lambda_integration
    ]
}

resource "aws_api_gateway_method_response" "gateway_method_response" {
    rest_api_id = aws_api_gateway_rest_api.crc_rest_api.id
    resource_id = aws_api_gateway_resource.getcounter.id
    http_method = aws_api_gateway_method.get_method.http_method
    status_code = "200"
    response_models = {
    "application/json" : "Empty"
    }
}

resource "aws_api_gateway_deployment" "deploy_crc_api"{
    rest_api_id = aws_api_gateway_rest_api.crc_rest_api.id
    
    lifecycle {
      create_before_destroy = true
    }

    depends_on = [
      aws_api_gateway_method.get_method,
      aws_api_gateway_integration.crc_lambda_integration,
      aws_api_gateway_integration_response.crc_api_gateway_integration_response
    ]
    
}

resource "aws_api_gateway_stage" "crc_stage_name" {
  deployment_id = aws_api_gateway_deployment.deploy_crc_api.id
  rest_api_id = aws_api_gateway_rest_api.crc_rest_api.id
  stage_name = "production"
}



# OUTPUTS
output "crc_rest_api_execution_arn"{
    value = aws_api_gateway_rest_api.crc_rest_api.execution_arn
}

output "gateway_method"{
    value = aws_api_gateway_method.get_method.http_method
}

output "resource_path"{
    value = aws_api_gateway_resource.getcounter.path
}

output api_gateway_stage_details {
    value = {
        "stage_name" = "production",
        "stage_url" = "${aws_api_gateway_stage.crc_stage_name.invoke_url}/${aws_api_gateway_resource.getcounter.path_part}"
        "How to set up" = <<EOF
1. Update the origins in your lambda code with your cloudfront url (crc_cloudfront_Url) and s3 url (crc_s3_url)
2. Regenerate your lamda zip file with the command: $ zip lambda_f.zip crc_lambda_function.py
3. Apply changees by running $ terraform apply
3. In your website js code you need to call the api (stage_url) with the update parameter set to true or false:
    <stage_url>?update=true | <stage_url>?update=false
    true to update the counter and false to return the current value.
EOF
    }
}