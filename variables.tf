variable "name" {
  description = "Generic name variable"
  type        = string
  default     = "Project Name"
}
variable "cidr" {
  description = "The CIDR of the VPC. This should be overwritten"
  type        = string
  default     = "0.0.0.0/0"
}

variable "public-subnet" {
  description = "The CIDR of thr Public Subnet. This should be over written"
  type        = string
  default     = "0.0.0.0/0"
}

variable "private-subnet" {
  description = "The CIDR of the Public Subnet. This should be overwritten"
  default     = "0.0.0.0/0"
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = "ami-0885b1f6bd170450c"
}


variable "instance-type" {
  description = "EC2 instance type. Can be overwritten but default is t2.micro"
  type        = string
  default     = "t2.micro"
}

variable "ec2-private-ip" {
  description = "Assign a private ip to ec2 instabceif desired. Must be overwritten and within a usable address range of private subnet"
  type        = string
  default     = "0.0.0.0"
}

variable "web-private-ip2" {
  type    = string
  default = "0.0.0.0"
}


variable "user_data" {
  description = "User data to provide when launching the instance"
  type        = string
  default     = null
}

variable "user_data_base_64" {
  description = "Use base64-encoded data directly"
  type        = string
  default     = null
}

variable "key_name" {
  description = "The key name for the instance"
  type        = string
  default     = " "
}


variable "vpc_tag_value" {
  description = "The value for the name tag of the vpc"
  type        = string
  default     = " "
}

variable "ec2count" {
  description = "The number of ec2 instances to create. 1 is the default."
  type        = string
  default     = "1"
}