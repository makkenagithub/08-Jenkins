data "aws_ssm_parameter" "bastion_sg_id" {
    name = "/${var.project_name}/${var.env}/bastion_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
    name = "/${var.project_name}/${var.env}/public_subnet_ids"
}

data "aws_ami" "suresh" {
    most_recent = true
    owners = ["973714476881"]

    filter {
        name = "name"
        values = ["RHEL-9-DevOps*"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}