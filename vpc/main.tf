locals {

}

module "vpc" {
  source = "./vpc"

  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "Dev"
    Project = "Virtual Private Cloud"
  }
}
