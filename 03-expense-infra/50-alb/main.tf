module "ingress_alb" {
  source = "terraform-aws-modules/alb/aws"

  internal = false  # internal is false here

  name    = "${local.resource_name}-${var.env}-ingress-alb"   # expense-dev-web-alb
  vpc_id  = local.vpc_id
  subnets = local.public_subnet_ids

  security_groups = [local.ingress_alb_sg_id]
  create_security_group = false
  enable_deletion_protection = false


  tags = merge(
    var.common_tags,
    var.ingress_alb_tags
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.ingress_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>I am web ALB HTTP in frontend apps</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.ingress_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.https_cert_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>I am web ALB HTTPS in frontend apps</h1>"
      status_code  = "200"
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"

  zone_name = "daws81s.online"

  records = [
    {
      name    = "expense-dev.daws81s.online" # *.-dev.daws81s.onine
      type    = "A"
      allow_overwrite= true
      alias   = {
        name    = module.web_alb.dns_name
        zone_id = module.web_alb.zone_id
      }
    }

  ]

}

# create lb target group for frontend
resource "aws_lb_target_group" "expense_tg" {
  name     = local.resource_name
  port     = 80 # port is 80 for front end
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  target_type = "ip"  # TARGET TYPE IS IP for PODS. DEFAULT VALUE IS instance FOR VMs

  # frontend app teams usually provide a url, if that is working fine then frontend app health is good. 
  # we are giving that url here in health_check block
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    matcher = "200-299"
    path = "/"  #frontend app team gives this.
    port = 8080 # port is 80 for front end, but k8s does not allow ports below 1024. Hence we are making frontend port health check as 8080 here and also in frontend nginx.conf file
    protocol = "HTTP"
    timeout = 6
    
  }

}

# alb listener rule - here we give lb listener arn, lb target group arn
# we can write multiple rules for a listener. A rule with low priority value is evaluated first
resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100    #low priority value rule will be evaluated first

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.expense_tg.arn
  }

  # host based routing
  condition {
    host_header {
      values = ["expense-dev-<domain name>"]  # eg: expense-dev.daws81s.online
    }
  }

}


