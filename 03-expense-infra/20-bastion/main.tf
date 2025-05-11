# copied the code from open source module
# https://github.com/terraform-aws-modules/terraform-aws-ec2-instance

# by default it uses the git hub source for open source modules

module "bastion_ec2" {

    # by default it uses the git hub source for open source modules
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.resource_name

  ami = data.aws_ami.suresh.id

  instance_type          = "t3.micro"
  #key_name               = "user1"
  #monitoring             = true


  vpc_security_group_ids = [local.bastion_sg_id]
  subnet_id              = local.public_subnet_id

  user_data = file("bastion.sh")    # it runs the bastion.sh script after creating ec2. We are using this bastion ec2 as workstation server.ami_ssm_parameter

  tags = merge(
    var.common_tags,
    var.bastion_tags,
    {
        Name = local.resource_name
    }
  )
}