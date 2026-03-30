terraform {
   backend "s3" {
     bucket = "aws-solutions-architect-tf-states"
     key    = "images-storage/terraform.tfstate"
     region = "eu-west-1"
     encrypt = true
     dynamodb_table = "aws-solutions-architect-tf-states-locks"
   }
}