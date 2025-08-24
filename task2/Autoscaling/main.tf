

variable "instance_type" {
  description = "EC2 instance type for the launch template"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "launch_template_name" {
  description = "Name prefix for the EC2 launch template"
  type        = string
  default     = "asg-launch-template"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the launch template"
  type        = list(string)
}

variable "user_data_path" {
  description = "Path to the user data script file"
  type        = string
  default     = ""
}

variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs for the Auto Scaling Group"
  type        = list(string)
}

resource "aws_launch_template" "asg_template" {
  name_prefix   = var.launch_template_name
  image_id      = var.ami_id
  instance_type = var.instance_type


  vpc_security_group_ids = var.vpc_security_group_ids


  user_data = filebase64(var.user_data_path)


  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.asg_name}-instance"
      Env         = var.env
      SSMManaged  = "true"
    }
  }
}



###AUTO-SCALING GROUP###

resource "aws_autoscaling_group" "web_asg" {
  name                      = var.asg_name
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = "EC2"
  health_check_grace_period = 60
  launch_template {
    id      = aws_launch_template.asg_template.id
    version = "$Latest"
  }
  

  tag {
    key                 = "Name"
    value               = "${var.asg_name}-ec2"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}


###SCALING POLICY AUTOMATIC###
resource "aws_autoscaling_policy" "target_tracking_cpu" {
  name                   = "${var.asg_name}-target-tracking-cpu"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value       = 50.0  # Aim to maintain 50% average CPU
    # cooldown           = 60    # Optional: wait time after a scale action
    # disable_scale_in   = false # Allow scale in (true = only scale out)
  }
}