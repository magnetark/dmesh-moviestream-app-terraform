output "notebook_url" {
  value = aws_sagemaker_notebook_instance.moviestream_notebook_instance.url
}

output "db_postgres_address" {
  value = aws_db_instance.moviestream_postgres_db.address
}