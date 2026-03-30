terraform {
   backend "s3" {
     bucket = "aws-solutions-architect-tf-states"
     key    = "s3-bucket/terraform.tfstate"
     region = "eu-west-1"
     encrypt = true
     dynamodb_table = "aws-solutions-architect-tf-states-locks"
   }
}
