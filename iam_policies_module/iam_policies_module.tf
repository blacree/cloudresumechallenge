resource "aws_iam_role" "crc_role"{
    name = "crc_role"
    tags = {
        Description = "cloud resume challenge role - Terraform provisioned"
    }
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
    })
}

resource "aws_iam_policy" "custom_cloudwatch_policy" {
    name = "crc_cloudwatch_policy"
    description = "Write permission to cloudwatch log groups"
    policy = file("./iam_policies_module/policy_documents/cloudwatch_policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_custom_cloudwatch_policy_to_role" {
    role = aws_iam_role.crc_role.name
    policy_arn = aws_iam_policy.custom_cloudwatch_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_dynamoDB_policy"{
    role = aws_iam_role.crc_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role" "cloudwatch_dynamoDB_streams_role" {
    name = "cloudwatch_dynamoDB_streams_role"
    managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"]
    tags = {
        Description = "Access dynamoDB streams and write to cloudwatch log groups"
    }

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

output "crc_iam_role_arn"{
    value = aws_iam_role.crc_role.arn
}

output "cloudwatch_dynamoDB_streams_iam_role_arn"{
    value = aws_iam_role.cloudwatch_dynamoDB_streams_role.arn
}