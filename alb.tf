#################
# Load Balancer #
#################

resource "aws_lb" "this" {
    name               = "${var.project}-LB"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [
        aws_security_group.load_balancer_sg.id
    ]
    subnets            = [
        aws_subnet.this[0].id,
        aws_subnet.this[1].id
    ]

    ### enable_deletion_protection = true
    enable_deletion_protection = false

    tags = {
		Name = "${var.project}-LB"
        Environment = var.environment
    }
}

resource "aws_lb_target_group" "this" {
    name                  = "Admin-Group"
    port                  = 443
    protocol              = "HTTPS"
    vpc_id                = data.aws_vpc.selected.id

    health_check {
        path                = "/account/login"
        healthy_threshold   = 2
        interval            = 30
        protocol            = "HTTPS"
        unhealthy_threshold = 2
    }
}

/*
##############################
# Load Balancer Target Group #
##############################

resource "aws_lb_target_group" "Admin-Group" {
    name                  = "Admin-Group"
    port                  = 443
    protocol              = "HTTPS"
    vpc_id                = data.aws_vpc.selected.id

    health_check {
        path                = "/account/login"
        healthy_threshold   = 2
        interval            = 30
        protocol            = "HTTPS"
        unhealthy_threshold = 2
    }
}

resource "aws_lb_target_group" "API-Group" {
    name                  = "API-Group"
    port                  = 8443
    protocol              = "HTTPS"
    vpc_id                = data.aws_vpc.selected.id

    health_check {
        path                = "/index.html"
        healthy_threshold   = 2
        interval            = 30
        protocol            = "HTTPS"
        unhealthy_threshold = 2
    }
}

resource "aws_lb_target_group" "Control-Group" {
    name                  = "Control-Group"
    port                  = 443
    protocol              = "HTTPS"
    vpc_id                = data.aws_vpc.selected.id

    health_check {
        path                = "/"
        healthy_threshold   = 2
        interval            = 30
        protocol            = "HTTPS"
        unhealthy_threshold = 2
    }
}

resource "aws_lb_target_group" "Portal-Group" {
    name                  = "Portal-Group"
    port                  = 443
    protocol              = "HTTPS"
    vpc_id                = data.aws_vpc.selected.id

    health_check {
        path                = "/login"
        healthy_threshold   = 2
        interval            = 30
        protocol            = "HTTPS"
        unhealthy_threshold = 2
    }
}

################
#  LB listener #
################

resource "aws_lb_listener" "admin" {
  load_balancer_arn = aws_lb.LB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${local.certificate_arn}"
   
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Admin-Group.arn
  }
}

# ADMIN
resource "aws_lb_listener_rule" "Admin-rule" {
  listener_arn = aws_lb_listener.admin.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Admin-Group.arn
  }

  condition {
    host_header {
      values = ["${local.admin_url}"]
    }
  }
}

# CONTROL
resource "aws_lb_listener_rule" "control-rule" {
  listener_arn = aws_lb_listener.admin.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Control-Group.arn
  }

  condition {
    host_header {
      values = ["${local.control_url}"]
    }
  }
}

# PORTAL
resource "aws_lb_listener_rule" "portal-rule" {
  listener_arn = aws_lb_listener.admin.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Portal-Group.arn
  }

  condition {
    host_header {
      values = ["${local.portal_url}"]
    }
  }
}

# API

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.LB.arn
  port              = "8443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${local.certificate_arn}"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.API-Group.arn
  }
}

resource "aws_lb_listener_rule" "api-rule" {
  listener_arn = aws_lb_listener.api.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.API-Group.arn
  }

  condition {
    host_header {
      values = ["${local.api_url}"]
    }
  }
}

#########################################
# Load Balancer Target Group Attachment #
#########################################

resource "aws_lb_target_group_attachment" "Admin-1-Group-attachment" {
    target_group_arn = aws_lb_target_group.Admin-Group.arn
    target_id        = aws_instance.ec2["Admin-1"].id
    port             = 443
}

resource "aws_lb_target_group_attachment" "Admin-2-Group-attachment" {
    target_group_arn = aws_lb_target_group.Admin-Group.arn
    target_id        = aws_instance.ec2["Admin-2"].id
    port             = 443
}

resource "aws_lb_target_group_attachment" "Control-1-Group-attachment" {
    target_group_arn = aws_lb_target_group.Control-Group.arn
    target_id        = aws_instance.ec2["Control-1"].id
    port             = 443
}

resource "aws_lb_target_group_attachment" "Control-2-Group-attachment" {
    target_group_arn = aws_lb_target_group.Control-Group.arn
    target_id        = aws_instance.ec2["Control-2"].id
    port             = 443
}

resource "aws_lb_target_group_attachment" "API-1-Group-attachment" {
    target_group_arn = aws_lb_target_group.API-Group.arn
    target_id        = aws_instance.ec2["API-1"].id
    port             = 8443
}

resource "aws_lb_target_group_attachment" "API-2-Group-attachment" {
    target_group_arn = aws_lb_target_group.API-Group.arn
    target_id        = aws_instance.ec2["API-2"].id
    port             = 8443
}

resource "aws_lb_target_group_attachment" "PORTAL-1-Group-attachment" {
    target_group_arn = aws_lb_target_group.Portal-Group.arn
    target_id        = aws_instance.ec2["Portal-1"].id
    port             = 443
}

resource "aws_lb_target_group_attachment" "PORTAL-2-Group-attachment" {
    target_group_arn = aws_lb_target_group.Portal-Group.arn
    target_id        = aws_instance.ec2["Portal-2"].id
    port             = 443
}

*/


