provider "aws" {
    region = "ap-south-1"
}

provider "vault" {
    address = "http://13.233.78.90:8200"
    skip_child_token = true
    auth_login {
      path = "auth/approle/login"
       parameters = {
        role_id = "bf187c47-180f-f785-9c35-f300653bfcf5"
        secret_id = "5b35a2d9-9ff4-7b47-bde3-df4bfa37a031"
      } 
    }
  }

/*resource "vault_kv_secret_v2" "name" {
  mount = "harish"
  name = "instance-secrets"  
}*/

## data is depricated we should be use resources only Deprecated. Please use new Ephemeral KVV2 Secret resource `vault_kv_secret_v2` instead

data "vault_kv_secret_v2" "example" {
   mount = "harish"
   name  = "instance-secrets"
}

resource "aws_instance" "name" {
   ami = data.vault_kv_secret_v2.example.data["ami"]
   instance_type = data.vault_kv_secret_v2.example.data["instance_type"]
   tags = {
   Name = "Test"
   secret_id = data.vault_kv_secret_v2.example.data["name"]
  }
}