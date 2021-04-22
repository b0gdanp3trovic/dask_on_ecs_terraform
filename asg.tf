data "aws_ami" "amazon_linux" {
    most_recent = true

    filter {
        name = "name"
        values = ["amzn-ami*amazon-ecs-optimized"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["amazon", "self"]
}

resource "aws_security_group" "ec2-sg" {
    name = "allow-all-sg"
    description = "allow all"
    vpc_id = data.aws_vpc.main.id

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_launch_configuration" "lc" {
    name_prefix    = "lc_dask_cluster"
    image_id = data.aws_ami.amazon_linux.id
    instance_type = "t2.small"

    lifecycle {
      create_before_destroy = true
    }
    iam_instance_profile = aws_iam_instance_profile.ecs_service_role.name
    #key_name    = var.key_name
    security_groups = [aws_security_group.ec2-sg.id]
    associate_public_ip_address = true
    user_data     = <<EOF
                    #! /bin/bash
                    sudo apt-get update
                    sudo echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config
                    EOF

}

resource "aws_autoscaling_group" "asg" {
    name =  "dask_cluster_asg"
    launch_configuration = aws_launch_configuration.lc.name
    desired_capacity = 3
    min_size = 3
    max_size = 10
    health_check_grace_period = 300
    vpc_zone_identifier = module.vpc.public_subnets
    protect_from_scale_in = false

    lifecycle {
        create_before_destroy = true
    }
}