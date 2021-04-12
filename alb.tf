resource "aws_lb" "dask_lb" {
    name = "dask-lb"
    load_balancer_type = "application"
    internal = false
    subnets = module.vpc.public_subnets

    security_groups = [aws_security_group.lb_sg.id]
}

resource "aws_security_group" "lb_sg" {
    name = "allow-all-lb-sg"
    vpc_id = data.aws_vpc.main.id
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}



resource "aws_lb_target_group" "scheduler_tg" {
    name = "dask-scheduler-tg"
    port = "8787"
    protocol ="HTTP"
    target_type = "ip"
    vpc_id = data.aws_vpc.main.id

    health_check {
      path = "/"
      healthy_threshold = 2
      unhealthy_threshold = 10
      timeout = 60
      interval = 300
      matcher = "300-399"
    }
}

resource "aws_lb_target_group" "jupyter_tg" {
    name = "jupyter-tg"
    port = "8888"
    protocol ="HTTP"
    target_type = "ip"
    vpc_id = data.aws_vpc.main.id

    health_check {
      path = "/"
      healthy_threshold = 2
      unhealthy_threshold = 10
      timeout = 60
      interval = 300
      matcher = "300-399"
    }
}



resource "aws_lb_listener" "jupyter_listener" {
    load_balancer_arn = aws_lb.dask_lb.arn 
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.jupyter_tg.arn
    }
}

resource "aws_lb_listener" "scheduler_listener" {
    load_balancer_arn = aws_lb.dask_lb.arn
    port = "8787"
    protocol = "HTTP"

    default_action {
      type="forward"
      target_group_arn = aws_lb_target_group.scheduler_tg.arn
    }
}