module "mysql_sg" {
    # source = "../../03-terraform-sg-module"
    # to give source from module prepared in GITHUB
    source = "git::https://github.com/makkenagithub/03-terraform-sg-module.git?ref=main"

    project_name = var.project_name
    env = var.env
    sg_name = "mysql"
    vpc_id  = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.mysql_sg_tags
}

module "bastion_sg" {
    #source = "../../03-terraform-sg-module"
    # to give source from module prepared in GITHUB
    source = "git::https://github.com/makkenagithub/03-terraform-sg-module.git?ref=main"

    project_name = var.project_name
    env = var.env
    sg_name = "bastion"
    vpc_id  = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.bastion_sg_tags
}

module "worker_node_sg" {
    #source = "../../03-terraform-sg-module"
    # to give source from module prepared in GITHUB
    source = "git::https://github.com/makkenagithub/03-terraform-sg-module.git?ref=main"

    project_name = var.project_name
    env = var.env
    sg_name = "worker-node"
    vpc_id  = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.worker_node_sg_tags
}

module "eks_control_plane_sg" {
    #source = "../../03-terraform-sg-module"
    # to give source from module prepared in GITHUB
    source = "git::https://github.com/makkenagithub/03-terraform-sg-module.git?ref=main"

    project_name = var.project_name
    env = var.env
    sg_name = "eks-control-plane"
    vpc_id  = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.eks_control_plane_sg_tags
}

module "ingress_alb_sg" {
    #source = "../../03-terraform-sg-module"
    # to give source from module prepared in GITHUB
    source = "git::https://github.com/makkenagithub/03-terraform-sg-module.git?ref=main"

    project_name = var.project_name
    env = var.env
    sg_name = "ingress-alb"  # expense-dev-app-alb
    vpc_id  = local.vpc_id
    common_tags = var.common_tags
    sg_tags = var.ingress_alb_sg_tags
}

resource "aws_security_group_rule" "ingress_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  # accept connections from this source
  # source_security_group_id = module.bastion_sg.id

  cidr_blocks       = ["0.0.0.0/0"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  
  # security group to apply this rule to
  security_group_id = module.ingress_alb_sg.id
}

resource "aws_security_group_rule" "worker_node_ingress_alb" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  # accept connections from this source
  source_security_group_id = module.ingress_alb_sg.id

  # cidr_blocks       = ["0.0.0.0/0"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  
  # security group to apply this rule to
  security_group_id = module.worker_node_sg.id
}

resource "aws_security_group_rule" "worker_node_eks_control_plane" {
  type              = "ingress"
  # allow all traffic from control plane to worker nodes and all protocols with below specifications
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # -1 means all protocols
  # accept connections from this source
  source_security_group_id = module.eks_control_plane_sg.id

  # cidr_blocks       = ["0.0.0.0/0"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  
  # security group to apply this rule to
  security_group_id = module.worker_node_sg.id
}

resource "aws_security_group_rule" "eks_control_plane_worker_node" {
  type              = "ingress"
  # allow all traffic from worker nodes to control plane and all protocols with below specifications
  from_port         = 0
  to_port           = 0
  protocol          = "-1"    # -1 means all protocols
  # accept connections from this source
  source_security_group_id = module.worker_node_sg.id

  # cidr_blocks       = ["0.0.0.0/0"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  
  # security group to apply this rule to
  security_group_id = module.eks_control_plane_sg.id
}

# below sg rule is to allow traffic from pod to pod, we all all traffic from vpc CIDR block to worker nodes
resource "aws_security_group_rule" "worker_node_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # -1 means all protocols
  # accept connections from this source
  #source_security_group_id = module.worker_node_sg.id

  cidr_blocks       = ["10.0.0.0/16"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  
  # security group to apply this rule to
  security_group_id = module.worker_node_sg.id
}

resource "aws_security_group_rule" "worker_node_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # accept connections from this source
  source_security_group_id = module.bastion_sg.id

  #cidr_blocks       = ["0.0.0.0/0"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  
  # security group to apply this rule to
  security_group_id = module.worker_node_sg.id
}

# we are using bastion ec2 as workstation server. So bastion ec2 should connect to control plane to get all cluster info like get nodes, get pods etc. Hence this sg rule is needed.
resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  # accept connections from this source
  source_security_group_id = module.bastion_sg.id

  #cidr_blocks       = ["0.0.0.0/0"]
  #ipv6_cidr_blocks  = [aws_vpc.example.ipv6_cidr_block]
  
  # security group to apply this rule to
  security_group_id = module.eks_control_plane_sg.id
}
