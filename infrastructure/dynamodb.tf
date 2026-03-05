resource "aws_dynamodb_table" "contacts" {
  name         = "${var.project_name}-submissions-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-submissions"
    Environment = var.environment
  }
}