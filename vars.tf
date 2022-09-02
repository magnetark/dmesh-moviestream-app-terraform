# ------------------------------
# MODULE: moviestream
# VARIABLES:
#   moviestream_dbuser:            (required)
#   moviestream_dbpass:            (required)
#   moviestream_dbname:            (required)
#   moviestream_dbport:            default 5432
#   region:                             default us-east-1
#   moviestram_db_rds_instance_type:    default "db.t3.small"
#   moviestram_notebook_instance_type:  default "db.t3.small"

variable "moviestream_dbuser" {}

variable "moviestream_dbpass" {}

variable "moviestream_dbname" {}

variable "moviestream_dbport" {
  default = 5432
}

variable "region" {
    default = "us-east-1"
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