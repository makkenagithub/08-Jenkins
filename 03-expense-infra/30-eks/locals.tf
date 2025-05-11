locals {
        # conver string list to list
    private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
    eks_control_plane_sg_id = data.aws_ssm_parameter.eks_control_plane_sg_id.value
    worker_node_sg_id = data.aws_ssm_parameter.worker_node_sg_id.value

}