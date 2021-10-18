
# _________________________________STATE vars_________________________________
variable "credentialsfile" {
  default = "/Users/lucac/.aws/credentials" 
}

variable "jar_local_path" {
  default = "C:/Users/lucac/firstapp/terraform-warehouse/wrsDEV-0.0.7-SNAPSHOT.jar"
}

variable "sh_local_path" {
  default = "C:/Users/lucac/firstapp/terraform-warehouse/script.sh"
}

variable "service_local_path" {
  default = "C:/Users/lucac/firstapp/terraform-warehouse/wrs.service"
}

# _________________________________NETWORK vars_________________________________
variable "cidr_vpc" {
  description = "blocco CIDR per la VPC"
  default     = "172.28.0.0/16"
}
variable "cidr_subnet" {
  description = "blocco CIDR per la subnet"
  type        = list(string)
  default     = ["172.28.0.0/24", "172.28.16.0/24"]
}
variable "availability_zone" {
  description = "zona di disponibilita' per la subnet"
  type        = list(string)
  default     = ["eu-west-1", "eu-west-1a", "eu-west-1b"]
}

# ___________________________________EC2 vars___________________________________
variable "instance_ami" {
  description = "AMI di una istanza EC2 AWS Linux 2 64bit"
  default     = "ami-0e4cd7bd9f518351d"
}
variable "instance_type" {
  description = "tipo di istanza EC2"
  default     = "t2.micro"
}
variable "environment_tag" {
  description = "tag dell'environment"
  default     = "Development"
}

# ___________________________________RDS vars___________________________________