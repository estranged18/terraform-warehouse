# terraform-warehouse
This repo contains the Terraform code to generate a complete AWS environment with Warehouse application running on a EC2 instance.

# components
The environment is composed of:
- Network:
  - VPC and internet gateway
  - S3 bucket endpoint
  - Public subnet for the application
  - Private subnet for the application
  - Private subnet for RDS database
  - Routing table
  - Security group for EC2
  - Security group for RDS database
  - DNS resolver
  
- Main:
  - S3 bucket with access policy
  - EC2 instance
  - RDS database
  
- Load Balancer:
  - Application lb
  - Listener
  - Target group
  - Attachment between EC2 instance and target group
  
# notes
S3 bucket is used to store the Warehouse JAR that will be accessed from the EC2 instance, so remember to edit both the JAR filename and the instance _user_data_ field, with the correct version.
  
The bucket contains also two scripts needed to run the application as a Linux service.
  
_user_data_ feld in EC2 instance is used to install Java Corretto 11, get the scripts and Warehouse JAR from S3 bucket, and launch it as a service on port 8080.
