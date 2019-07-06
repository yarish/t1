terraform {
  required_version = ">= 0.12, <= 0.12.13"
  backend "s3" {
    # Replace this with our bucket name!
    bucket         = "hellodk02"
#    key            = "global/s3/terraform.tfstate"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "ap-south-1"
    # Replace this with our DynamoDB table name!
    dynamodb_table = "demo_table"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_db_instance" "demo_db_instance" {
  identifier_prefix   = "demo-db"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = "demo_database"
  username            = "admin"
  # How should we set the password?
#  password            = "???"
  password            = "${var.db_password}"
}

