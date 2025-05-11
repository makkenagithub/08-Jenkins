data "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project_name}/${var.env}/vpc_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
    name = "/${var.project_name}/${var.env}/public_subnet_ids"
}

data "aws_ssm_parameter" "ingress_alb_sg_id" {
    name = "/${var.project_name}/${var.env}/ingress_alb_sg_id"
}

data "aws_ssm_parameter" "https_cert_arn" {
    name = "/${var.project_name}/${var.env}/https_cert_arn"
}