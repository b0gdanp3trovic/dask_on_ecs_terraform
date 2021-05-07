resource "aws_ecs_cluster" "dask_cluster" {
    name = var.cluster_name 
    capacity_providers = [aws_ecs_capacity_provider.cp.name]
}

resource "aws_ecs_cluster" "dask_cluster2" {
    name = var.cluster_name2 
    capacity_providers = [aws_ecs_capacity_provider.cp2.name]
}

resource "aws_ecs_capacity_provider" "cp" {
    name = "capacity-provider-dask"
    auto_scaling_group_provider {
      auto_scaling_group_arn = aws_autoscaling_group.asg.arn
      managed_termination_protection = "DISABLED"

      managed_scaling {
        status = "DISABLED"
      }
    }
}

resource "aws_ecs_capacity_provider" "cp2" {
    name = "capacity-provider-dask2"
    auto_scaling_group_provider {
      auto_scaling_group_arn = aws_autoscaling_group.asg2.arn
      managed_termination_protection = "ENABLED"
      managed_scaling {
        status = "DISABLED"
      }
    }
}

resource "aws_ecs_task_definition" "task_definition_scheduler" {
    family  = "task-scheduler"
    container_definitions = file("container-definitions/task-scheduler.json")
    network_mode = "awsvpc"
}

resource "aws_ecs_task_definition" "task_definition_worker" {
    family  = "task-worker"
    container_definitions = file("container-definitions/task-worker.json")
    network_mode = "awsvpc"
}

resource "aws_ecs_task_definition" "task_definition_jupyter" {
    family  = "task-jupyter"
    container_definitions = file("container-definitions/task-jupyter.json")
    network_mode = "bridge"
}

resource "aws_ecs_service" "service_jupyter" {
    name = "service-jupyter"
    cluster = aws_ecs_cluster.dask_cluster2.id
    task_definition = aws_ecs_task_definition.task_definition_jupyter.arn
    desired_count = 1

    #aws_security_group" "ec2-sg"


    ordered_placement_strategy {
        type = "binpack"
        field = "cpu"
    }

    load_balancer {
      target_group_arn = aws_lb_target_group.jupyter_tg.arn
      container_name = "container-jupyter"
      container_port = 8888
    }

    lifecycle {
      ignore_changes = [desired_count]
    }
    


    launch_type = "EC2"
    depends_on = [ aws_lb_listener.jupyter_listener ]
}



resource "aws_ecs_service" "service_scheduler" {
    name = "service-scheduler"
    cluster = aws_ecs_cluster.dask_cluster2.id
    task_definition = aws_ecs_task_definition.task_definition_scheduler.arn
    desired_count = 1


    ordered_placement_strategy {
        type = "binpack"
        field = "cpu"
    }

    load_balancer {
      target_group_arn = aws_lb_target_group.scheduler_tg.arn
      container_name = "container-scheduler"
      container_port = 8787
    }

    service_registries {
        registry_arn = aws_service_discovery_service.sd_dask.arn
        container_name = "container-scheduler"
    }

    lifecycle {
      ignore_changes = [desired_count]
    }

    network_configuration {
        subnets = module.vpc.public_subnets
        security_groups = [aws_security_group.ec2-sg.id]
    }

    launch_type = "EC2"
    depends_on = [ aws_lb_listener.scheduler_listener ]
}

resource "aws_ecs_service" "service_worker" {
    name = "service-worker"
    cluster = aws_ecs_cluster.dask_cluster.id
    task_definition = aws_ecs_task_definition.task_definition_worker.arn
    desired_count = 1

    ordered_placement_strategy {
        type = "binpack"
        field = "cpu"
    }

    lifecycle {
      ignore_changes = [desired_count]
    }

    network_configuration {
        subnets = module.vpc.public_subnets
        security_groups = [aws_security_group.ec2-sg.id]
    }

    launch_type = "EC2"
}

resource "aws_cloudwatch_log_group" "log_group" {
    name = "/ecs/dask"
}