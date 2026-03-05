# Jenkins için Security Group — hangi portlar açık olsun?
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Jenkins server security group"

  # SSH erişimi — sadece senin IP'nden
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Sonra kendi IP'nle kısıtlayabiliriz
  }

  # Jenkins web arayüzü
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tüm dışa çıkan trafiğe izin ver
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-jenkins-sg"
    Environment = var.environment
  }
}

# Jenkins EC2 instance
resource "aws_instance" "jenkins" {
  ami                    = "ami-0c02fb55956c7d316"  # Amazon Linux 2 (us-east-1)
  instance_type          = "t3.small"               # Jenkins için minimum bu olmalı
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = var.key_pair_name

  # EC2 ayağa kalkınca Jenkins'i otomatik kur
  user_data = <<-EOF
    #!/bin/bash
    yum update -y

    # Java kur (Jenkins için gerekli)
    yum install -y java-17-amazon-corretto

    # Jenkins repo ekle ve kur
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    yum install -y jenkins

    # AWS CLI v2 kur (deploy için)
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    # Jenkins'i başlat
    systemctl enable jenkins
    systemctl start jenkins
  EOF

  tags = {
    Name        = "${var.project_name}-jenkins"
    Environment = var.environment
  }
}

# Jenkins EC2'ya IAM Role — S3 ve Lambda'ya deploy yetkisi
resource "aws_iam_role" "jenkins" {
  name = "${var.project_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "jenkins_policy" {
  name = "${var.project_name}-jenkins-policy"
  role = aws_iam_role.jenkins.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:PutBucketWebsite"
        ]
        Resource = [
          aws_s3_bucket.frontend.arn,
          "${aws_s3_bucket.frontend.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction"
        ]
        Resource = [
          aws_lambda_function.submit_contact.arn,
          aws_lambda_function.get_contacts.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = "*"
      }
    ]
  })
}

# IAM Role'u EC2'ya bağla
resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins.name
}