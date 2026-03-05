# Lambda'nın üstleneceği rol (kimlik kartı)
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# DynamoDB erişim yetkisi
resource "aws_iam_role_policy" "lambda_dynamodb_policy" {
  name = "${var.project_name}-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:PutItem",
        "dynamodb:Scan",
        "dynamodb:GetItem"
      ]
      Resource = aws_dynamodb_table.contacts.arn
    }]
  })
}

# CloudWatch log yetkisi (hata ayıklama için)
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Python kodlarını zip'le — Terraform bunu AWS'e yükleyecek
data "archive_file" "submit_contact" {
  type        = "zip"
  source_file = "${path.module}/../backend/submit_contact.py"
  output_path = "${path.module}/submit_contact.zip"
}

data "archive_file" "get_contacts" {
  type        = "zip"
  source_file = "${path.module}/../backend/get_contacts.py"
  output_path = "${path.module}/get_contacts.zip"
}

# Submit Lambda
resource "aws_lambda_function" "submit_contact" {
  filename         = data.archive_file.submit_contact.output_path
  function_name    = "${var.project_name}-submit-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "submit_contact.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.submit_contact.output_base64sha256

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.contacts.name
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Name        = "${var.project_name}-submit"
    Environment = var.environment
  }
}

# Get Contacts Lambda
resource "aws_lambda_function" "get_contacts" {
  filename         = data.archive_file.get_contacts.output_path
  function_name    = "${var.project_name}-get-contacts-${var.environment}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "get_contacts.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.get_contacts.output_base64sha256

  environment {
    variables = {
      TABLE_NAME  = aws_dynamodb_table.contacts.name
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Name        = "${var.project_name}-get-contacts"
    Environment = var.environment
  }
}