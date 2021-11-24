output "alb_sg_id" {
  value = aws_security_group.alb_security_group.id
}

output "esc_sg_id" {
  value = aws_security_group.ecs_tasks.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}