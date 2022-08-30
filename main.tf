# --------------------------------
# VPC RESOURCES
# --------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name            = "vpc_moviestream"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_security_group" "notebook" {
  name        = "allow_public_notebook"
  description = "Allow public inbound for notebook"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow Jupyter"
    from_port   = 8888
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "allow_notebook" })
}

resource "aws_security_group" "database" {
  name        = "allow_public_database"
  description = "Allow public inbound for database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow db connection"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "allow_database" })
}

# --------------------------------
# IAM ROLE FOR NOTEBOOK
# --------------------------------

#data "aws_iam_role" "sagemaker_role" {
#  name = "AmazonSageMakerServiceCatalogProductsUseRole"
#}

resource "aws_iam_role" "notebookrole" {
  name = "moviestrea-app-notebookrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.policy_one.arn]

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_policy" "policy_one" {
  name = "moviestream-app-kinesis-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["kinesis:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# --------------------------------
# NOTEBOOK INSTANCE
# --------------------------------

resource "aws_sagemaker_code_repository" "moviestream_app_code" {
  code_repository_name = "moviestream-app-notebooks"

  git_config {
    repository_url = "https://github.com/magnetark/dmesh-moviestream-app-notebooks"
  }
}

resource "aws_sagemaker_notebook_instance" "moviestream_notebook_instance" {
  name          = "moviestream-notebook-instance"
  role_arn      = aws_iam_role.notebookrole.arn#data.
  instance_type = var.moviestram_notebook_instance_type
  subnet_id     = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.notebook.id]
  default_code_repository = aws_sagemaker_code_repository.moviestream_app_code.code_repository_name

  tags = merge(var.tags, { Name = "moviestream_notebook_instance" })
}

# --------------------------------
# POSTGRES DB
# --------------------------------

resource "aws_db_subnet_group" "moviestream_postgres_subnet" {
  name       = "moviestream_postgres_subnet"
  subnet_ids = module.vpc.public_subnets

  tags = merge(var.tags, { Name = "moviestream_postgres_subnet" })
}

resource "aws_db_instance" "moviestream_postgres_db" {
  identifier             = "moviestream-postgres"
  instance_class         = var.moviestram_db_rds_instance_type
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "14.3"
  db_name                = "moviestreamdb"
  port                   = var.moviestream_db_port
  username               = var.moviestream_db_username
  password               = var.moviestream_db_password
  db_subnet_group_name   = aws_db_subnet_group.moviestream_postgres_subnet.name
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = merge(var.tags, { Name = "moviestream_postgres_db" })
}