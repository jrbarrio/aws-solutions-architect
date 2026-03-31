variable "bucket_name" {
  type = string
}

variable "dynamodb_table_id" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}

variable "tags" {
    type = map(string)
}