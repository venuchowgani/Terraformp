provider "aws" {
    region      = "us-east-1"
}

resource "aws_s3_bucket" "b" {
  bucket = "v-tf-s3-1"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}