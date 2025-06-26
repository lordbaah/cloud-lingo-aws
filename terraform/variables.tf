variable "project_name" {
  description = "Name of project"
  type        = string
  default     = "cloudlingo"
}


# Variable definition for AWWS Region
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

#variables for Roles and Policies
variable "cloudlingo_role_name" {
  description = "Name of the IAM role for CloudLingo Lambda"
  type        = string
  default     = "cloudlingo-translate-role"
}

variable "cloudlingo_policy_name" {
  description = "Name of the IAM policy for CloudLingo Lambda"
  type        = string
  default     = "cloudlingo-translate-s3-policy"
}
