terraform {
  backend "s3" {
    bucket         = "networking-ca1-20068144"
    key            = "terraform/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
  }
}
