output "alb_url" {
    value = aws_lb.ingress.dns_name
}

output "environment" {
    value = local.workspace
}

output "image" {
    value = var.appImage
}

