terraform {
  backend "s3" {
    bucket         = "ironman-config-prd-use2"
    key            = "terraform/prd/us/use2/env/prd/eks/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "tf-state-lock-eks"
  }
}

