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

# ------
