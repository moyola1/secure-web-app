# Module outputs
output "instance_public_ip" {
  value = aws_instance.secure-web-app-server.public_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_id_cidr" {
  value = aws_vpc.main.cidr_block
}

output "vpc_subnet_id" {
  value = aws_subnet.public.id
}

output "vpc_subnet_cidr" {
  value = aws_subnet.public.cidr_block
}

output "availability_zone" {
  value = aws_subnet.public.availability_zone
}

output "account_info" {
  value = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}"
}

