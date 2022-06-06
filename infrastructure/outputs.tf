output "jenkins_ip" {
    value = aws_instance.jenkins.public_ip
    description = "jenkins instance public ip"
}

output "application_ip" {
    value = aws_instance.application.public_ip
    description = "application instance public ip"
}