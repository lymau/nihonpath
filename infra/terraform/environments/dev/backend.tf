terraform {
  backend "s3" {
    bucket         = "nihonpath-terraform-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "ap-southeast-3"
    dynamodb_table = "nihonpath-terraform-locks-dev"
    encrypt        = true
  }
}
