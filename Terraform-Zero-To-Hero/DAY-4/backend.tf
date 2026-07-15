terraform {
  backend "s3" {
    bucket = "harish-s3-demo-jobiak-xyz"
    region = "ap-south-1"
    key = "Harish/terraform.tfstate" 
    dynamodb_table = "terraform_lock"
  }
}