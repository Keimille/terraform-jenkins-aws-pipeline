output "vpc_id" {
  description = "The ID of the VPC"
  value       = concat(aws_vpc.main_vpc.*.id, [""])[0]
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = concat(aws_vpc.main_vpc.*.arn, [""])[0]
}

output "Jenkins_Master_IPs" {
  description = "The public IP address of created Jenkins Master resource"
  value       = concat(aws_instance.Jenkins-Master.*.public_ip)
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = concat(aws_vpc.main_vpc.*.default_security_group_id, [""])[0]
}