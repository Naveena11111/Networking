terraform {
  backend "s3" {
    bucket         = "networking-ca1-20058689"
    key            = "terraform/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}
