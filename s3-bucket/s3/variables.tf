variable "bucket_name" {
  type = string
}

variable "whitelist_cidrs" {
  type = list(string)
}

variable "tags" {
    type = map(string)
}