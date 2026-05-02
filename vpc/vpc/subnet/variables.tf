variable "tags" {
  type = map(string)
}

variable "cidr_block" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = false
}
