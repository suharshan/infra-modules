resource "aws_dynamodb_table" "signup-table" {
  name           = "signups"
  billing_mode   = "PROVISIONED"
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "email"

  attribute {
    name = "email"
    type = "S"
  }

  tags = {
    Name        = "email"
    Environment = var.env
    Terraform = "true"
  }
}
