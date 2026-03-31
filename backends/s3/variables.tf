variable "bucket_name" {
  type = string
}

variable "identifiers" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}