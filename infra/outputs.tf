output "instance_id" {
  description = "The server's ID (used to stop and start it)"
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "The server's public IP address"
  value       = aws_instance.app.public_ip
}

output "website_url" {
  description = "Where the app will be, once deployed in Step 8"
  value       = "http://${aws_instance.app.public_ip}"
}

output "ssh_command" {
  description = "How to log in"
  value       = "ssh -i ${trimsuffix(var.ssh_public_key_path, ".pub")} ubuntu@${aws_instance.app.public_ip}"
}