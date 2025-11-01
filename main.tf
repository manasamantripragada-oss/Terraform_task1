terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6.0"
}

# ---------- VARIABLES ----------
variable "key_name" {
  description = "Name for the key pair"
  type        = string
}

variable "create_key_pair_in_region2" {
  description = "Whether to create the key pair in region 2"
  type        = bool
  default     = true
}

variable "public_key_material" {
  description = "Public key material (contents of .pub file)"
  type        = string
}

# ---------- PROVIDERS ----------
provider "aws" {
  region = "us-east-1" # Primary region
}

provider "aws" {
  alias  = "r2"
  region = "us-west-2" # Secondary region
}

# ---------- KEY PAIRS ----------
resource "aws_key_pair" "key_r1" {
  key_name   = var.key_name
  public_key = var.public_key_material
}

resource "aws_key_pair" "key_r2" {
  count       = var.create_key_pair_in_region2 && length(trimspace(var.public_key_material)) > 0 ? 1 : 0
  provider    = aws.r2
  key_name    = var.key_name
  public_key  = var.public_key_material
}

# ---------- EC2 INSTANCES ----------
resource "aws_instance" "instance_r1" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_r1.key_name

  tags = {
    Name = "Terraform-Instance-Region1"
  }
}

resource "aws_instance" "instance_r2" {
  provider      = aws.r2
  ami           = "ami-0b2f6494ff0b07a0e" # Amazon Linux 2 (us-west-2)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_r2[0].key_name

  tags = {
    Name = "Terraform-Instance-Region2"
  }
}

# ---------- OUTPUTS ----------
output "region1_instance_public_ip" {
  description = "Public IP of instance in region 1"
  value       = aws_instance.instance_r1.public_ip
}

output "region2_instance_public_ip" {
  description = "Public IP of instance in region 2"
  value       = aws_instance.instance_r2.public_ip
}
