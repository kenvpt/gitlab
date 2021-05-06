resource "aws_launch_template" "asg_template {
  name_prefix   = "asg_template"
  image_id      = data.aws_ami.centos.id
  instance_type = "t2.xlarge"
}

resource "aws_autoscaling_group" "asg" {
  capacity_rebalance  = true
  name                = "asg_spot"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete        = true
  desired_capacity    = 3
  max_size            = 5
  min_size            = 3
  vpc_zone_identifier = [aws_subnet.public_subnet.1.id, aws_subnet.public_subnet.2.id, aws_subnet.public_subnet.3.id]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 25
      spot_allocation_strategy                 = "lowest-price"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.asg_template.id}"

      override {
        instance_type     = "t2.2xlarge"
        weighted_capacity = "3"
      }

      override {
        instance_type     = "c3.large"
        weighted_capacity = "2"
      }
    }
  }
}
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  elb                    = "${aws_elb.elb.id}"
}
