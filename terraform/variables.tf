variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environments" {
  description = "Environment configurations"
  type = map(object({
    cluster_version = string
    desired_size    = number
    min_size        = number
    max_size        = number
    instance_types  = list(string)
  }))
  default = {
    prod = {
      cluster_version = "1.30"
      desired_size    = 3
      min_size        = 2
      max_size        = 5
      instance_types  = ["t2.medium"]
    }
    staging = {
      cluster_version = "1.30"
      desired_size    = 1
      min_size        = 1
      max_size        = 3
      instance_types  = ["t2.small"]
    }
  }
}

variable "aws_access_key_id" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS secret"
  type        = string
}
