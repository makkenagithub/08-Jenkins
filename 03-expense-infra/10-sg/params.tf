# store the required IDs/values in ssm param store
resource "aws_ssm_parameter" "mysql_sg_id" {

    #/expense/dev/mysql_sg_id
  name  = "/${var.project_name}/${var.env}/mysql_sg_id"
  type  = "String"
  value = module.mysql_sg.id
}

resource "aws_ssm_parameter" "bastion_sg_id" {
    #/expense/dev/bastion_sg_id
  name  = "/${var.project_name}/${var.env}/bastion_sg_id"
  type  = "String"
  value = module.bastion_sg.id
}

resource "aws_ssm_parameter" "worker_node_sg_id" {
    #/expense/dev/worker_node_sg
  name  = "/${var.project_name}/${var.env}/worker_node_sg_id"
  type  = "String"
  value = module.worker_node_sg.id
}

resource "aws_ssm_parameter" "eks_control_plane_sg_id" {
    #/expense/dev/eks_control_plane_sg
  name  = "/${var.project_name}/${var.env}/eks_control_plane_sg_id"
  type  = "String"
  value = module.eks_control_plane_sg.id
}

resource "aws_ssm_parameter" "ingress_alb_sg_id" {
    #/expense/dev/ingress_alb_sg
  name  = "/${var.project_name}/${var.env}/ingress_alb_sg_id"
  type  = "String"
  value = module.ingress_alb_sg.id
}
