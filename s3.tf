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

# Il JAR si trova gia' sul bucket
resource "aws_s3_bucket_object" "obj1" {
  # carico script.sh sul bucket
  bucket = aws_s3_bucket.tfs3bucket.id
  key    = "script.sh"
  acl    = "private"   
  source = "script.sh"

  etag = filemd5("script.sh")
}
resource "aws_s3_bucket_object" "obj2" {
  # carico wrs.service sul bucket
  bucket = aws_s3_bucket.tfs3bucket.id
  key    = "wrs.service"
  acl    = "private"   
  source = "wrs.service"

  etag = filemd5("wrs.service")
}

#
#
#
##############################################################
##                                                          ## 
##   questo bucket e' esclusivo per lo stato di terraform   ## 
##                                                          ##
##############################################################
#
#resource "aws_s3_bucket" "terraform_state" {
#  bucket = "terraform-state-warehouse"
#
#
#  lifecycle {
#    prevent_destroy = true
#  }
#  versioning {
#    enabled = true
#  }
#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        sse_algorithm = "AES256"
#      }
#    }
#  }
#}
#resource "aws_dynamodb_table" "terraform_lock" {
#  name         = "terraform-tfstate-lock"
#  billing_mode = "PAY_PER_REQUEST"
#  hash_key     = "LockID"
#
#  attribute {
#    name  = "LockID"
#    type = "S"
#  }
#}
#