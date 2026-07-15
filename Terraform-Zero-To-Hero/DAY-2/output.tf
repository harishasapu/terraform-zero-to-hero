output "instance_public_ip" {
    description = "Public IP of the EC2 instance"
    value = aws_instance.this.public_ip
}

output "instance_type" {
    value = aws_instance.this.instance_type  
}

output "instance_id" {
    value = aws_instance.this.id  
}