resource "aws_instance" "harish" {
    ami = "ami-05d2d839d4f73aafb"
    instance_type = "t3.micro"
  tags = {
    Name = "Harish"
  }
  
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "harish-s3-demo-jobiak-xyz"
}

resource "aws_dynamodb_table" "terraform_lock" {
   name = "terraform_lock"
   billing_mode = "PAY_PER_REQUEST"
   hash_key = "LockID"

   attribute {
     name = "LockID"
     type = "S"
   }
  
}


## terraform apply -lock=false
