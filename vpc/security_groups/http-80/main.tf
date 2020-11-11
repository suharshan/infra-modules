resource "aws_security_group" "this" {
  name        = var.name
  vpc_id      = var.vpc_id
  description = "Security group for ${var.name}"

  tags = {
    Name     = var.name
    Env      = var.env
    Provider = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    protocol    = "TCP"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
