resource "aws_dynamodb_table" "crc-dynamodb-table" {
  name           = "crc_dynamoDB_table"
  billing_mode   = "PAY_PER_REQUEST"
#   read_capacity  = 20
#   write_capacity = 20
  hash_key       = "number of views"
#   range_key      = "GameTitle"

  attribute {
    name = "number of views"
    type = "S"
  }

  tags = {
    Name        = "crc-dynamoDB-table"
    Description = "Terraform provisioned table"
  }
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

output "crc_dynamoDB_stream_arn"{
    value = aws_dynamodb_table.crc-dynamodb-table.stream_arn
}