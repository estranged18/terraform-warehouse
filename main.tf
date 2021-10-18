
# ________________________________PROVIDER________________________________
provider "aws" {
  shared_credentials_file = var.credentialsfile
  region = "${var.availability_zone[0]}"
}

terraform {
  required_version = ">= 1.0.8"
}

# ________________________________BUCKET S3________________________________
resource "aws_s3_bucket" "tfs3bucket" {
  # contenente il JAR di warehouse (profile: dev)
  bucket = "tfs3bucket"
  acl    = "private"   

  tags = {
    Name        = "terraform-s3-bucket"
    Environment = "${var.environment_tag}"
  }
}
resource "aws_s3_bucket_policy" "tfs3bucket_policy" {
  # con questa policy posso accedere al bucket S3 privato fintanto
  # che mi trovo all'interno della VPC. Quindi dall'istanza EC2 posso
  # scaricare il JAR senza accedere con le credenziali AWS
  bucket = aws_s3_bucket.tfs3bucket.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Policy1"
    Statement = [
      {
        Sid       = "access to specific VPC"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.tfs3bucket.arn,
          "${aws_s3_bucket.tfs3bucket.arn}/*",
        ]
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = "${aws_vpc_endpoint.s3.id}"
          }
        }
      },
    ]
  })
}

# Il JAR si trova gia' sul bucket, viene caricato con l'esecuzione
# del workflow della repository https://github.com/estranged18/warehouse

resource "aws_s3_bucket_object" "obj2" {
  # carico script.sh sul bucket
  bucket = aws_s3_bucket.tfs3bucket.id
  key    = "script.sh"
  acl    = "private"   
  source = "${var.sh_local_path}"

  etag   = filemd5("${var.sh_local_path}")
}
resource "aws_s3_bucket_object" "obj3" {
  # carico wrs.service sul bucket
  bucket = aws_s3_bucket.tfs3bucket.id
  key    = "wrs.service"
  acl    = "private"   
  source = "${var.service_local_path}"

  etag   = filemd5("${var.service_local_path}")
}

# ________________________________EC2 INSTANCE________________________________
resource "aws_instance" "terraform_wrs_dev" {
  ami                    = "${var.instance_ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.wrs_public_subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.wrs_sg.id}"]
  iam_instance_profile   = "AWSEC2InstanceAccessToS3Role"

    user_data = <<HEREDOC
      #!/bin/bash
      #
      ###############################################################################
      ##                                                                           ##
      ##   Provision the Spring Boot application                                   ##
      ##   Adapted from the following blog post:                                   ##
      ##   http://zoltanaltfatter.com/2016/12/17/spring-boot-application-on-ec2/   ##
      ##                                                                           ##
      ###############################################################################
      #
      # installo java per amazon linux 2
      sudo yum install java-11-amazon-corretto

      mkdir /home/ec2-user/workspace
      cd /etc/systemd/system
      wget https://tfs3bucket.s3.eu-west-1.amazonaws.com/wrs.service

      # give ec2-user write permission to workspace
      # 777 means all permissions
      cd /home/ec2-user
      sudo chmod 777 workspace

      cd /home/ec2-user/workspace
      wget https://tfs3bucket.s3.eu-west-1.amazonaws.com/wrsDEV-0.0.7-SNAPSHOT.jar
      wget https://tfs3bucket.s3.eu-west-1.amazonaws.com/script.sh

      sudo chmod 777 script.sh

      # start wrs.service
      sudo systemctl daemon-reload
      sudo systemctl enable wrs.service
      sudo systemctl start wrs
    HEREDOC

  tags = {
    Name        = "terraform-wrs-dev"
    Environment = "${var.environment_tag}"
  }  
}

# ___________________________________RDS DB___________________________________

