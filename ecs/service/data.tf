# data "aws_vpc" "vpc" {
#   tags = {
#     Name = "services-vpc-${var.environment}"
#   }
# }

# data "aws_subnet_ids" "private" {
#   vpc_id = data.aws_vpc.vpc.id

#   tags = {
#     Tier = "private"
#   }
# }

# data "aws_security_group" "alb_sg" {
#   tags = {
#     Name = "${var.name}-alb-${var.environment}"
#   }
# }
