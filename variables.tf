
# _________________________________STATE vars_________________________________
variable "AWS_ID"{
  type    = string
  default = ""
  # valore assegnato a runtime: AWS_ACCESS_KEY_ID
}

variable "AWS_SECRET_KEY"{
  type    = string
  default = ""
  # valore assegnato a runtime: AWS_SECRET_ACCESS_KEY
}

variable "sh_local_path" {
  default = "terraform-warehouse/script.sh"
}

variable "service_local_path" {
  default = "terraform-warehouse/wrs.service"
}

# _________________________________NETWORK vars_________________________________
variable "cidr_vpc" {
  description = "blocco CIDR per la VPC"
  default     = "10.0.0.0/16"
}
variable "cidr_subnet" {
  description = "blocco CIDR per la subnet"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  # il primo CIDR e' per la subnet pubblica, il secondo e' per 
  # la subnet privata: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario3.html
}
variable "availability_zone" {
  description = "zona di disponibilita' per la subnet"
  type        = list(string)
  default     = ["eu-west-1", "eu-west-1a", "eu-west-1b", "eu-west-1c"]
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

variable "RDS_USER"{
  type    = string
  default = ""
  # valore assegnato a runtime: RDS_USERNAME
}

variable "RDS_PASSWORD"{
  type    = string
  default = ""
  # valore assegnato a runtime: RDS_PASSWORD
}

variable "RDS_DB_NAME"{
  type    = string
  default = ""
  # valore assegnato a runtime: RDS_DB_NAME
}

variable "RDS_PORT"{
  type    = string
  default = "0"
  # valore assegnato a runtime: RDS_PORT
}



