output "public_ip" {
  value = aws_instance.example.public_ip 
}

output "instance-type" {
  value = aws_instance.example.instance_type
}