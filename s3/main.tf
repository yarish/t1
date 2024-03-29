terraform {
  required_version = ">= 0.12, <= 0.12.13"
  backend "s3" {
    # Replace this with our bucket name!
    bucket         = "hellodk02"
#    key            = "global/s3/terraform.tfstate"
    key            = "demo_workspace/terraform.tfstate"
    region         = "ap-south-1"
    # Replace this with our DynamoDB table name!
    dynamodb_table = "demo_table"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.bucket_name}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
  server_side_encryption_configuration {  
    rule {
      apply_server_side_encryption_by_default {   
        sse_algorithm = "AES256"     
      }   
    } 
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name         = "demo_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}