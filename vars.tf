# ------------------------------
# MODULE: moviestream
# VARIABLES:
#   project_prefix:                     (required)
#   moviestream_db_username:            (required)
#   moviestream_db_password:            (required)
#   moviestream_db_port:                default 5432
#   region:                             default us-east-1
#   moviestram_db_rds_instance_type:    default "db.t3.small"
#   moviestram_notebook_instance_type:  default "db.t3.small"

variable "project_prefix" {}

variable "moviestream_db_username" {}

variable "moviestream_db_password" {}

variable "region" {
    default = "us-east-1"
}

variable "moviestream_db_port" {
  default = 5432
}

variable "moviestram_db_rds_instance_type" {
  default = "db.t3.small"
}

variable "moviestram_notebook_instance_type" {
  default = "ml.t2.medium"
}

variable "tags" {
  description = ""
  type        = map(any)
  default     = {}
}