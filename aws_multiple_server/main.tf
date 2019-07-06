terraform {
  required_version = ">= 0.12, <= 0.12.13"
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "hellodk02"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  version = "~> 2.17"
  region = var.region
}

# data "aws_availability_zones" "all" {}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_launch_configuration" "demo_lc" {
  image_id = "ami-07d40e643a23a9813"
  key_name = aws_key_pair.demo_key_pair.key_name
#  count         = "${var.instance_count}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.demo_instance_sg.id}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "<html>Good, Day</html>" > /home/ubuntu/index.html
              echo "${data.terraform_remote_state.db.outputs.address}" >> index.html
              echo "${data.terraform_remote_state.db.outputs.port}" >> index.html
              apt update -y
              apt install -y nginx
              systemctl enable nginx
              systemctl start nginx
              mv /home/ubuntu/index.html /var/www/html/index.nginx-debian.html 
              systemctl restart nginx
              EOF

/*  tag = {
    Name = "demo-machine-${count.index + 1}"
    Owner = "Deepak"
    Team = "Level 1"
    Manager = "dk"
  }*/
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "demo_instance_sg" {
  vpc_id = aws_default_vpc.default.id
  name = "demo_instance_sg"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "demo_key_pair" {
  key_name   = "demo_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGuCugFDxQfmM9LIeP6TOOh8sKUBbsduEvLzNeKhiLGZNoSg8sdRGOkp9jOWelIIW5jxDk9PB7dT49zEgk29OzRI8VyTKDYVx49H15hEmtITKWNrhpWu7VmmUr0h2E7aJ/0R7F1ybketIqmwq/EK8yNIjtLIv+PS9B0GiW7K1CZyg3jS7qB2IDxlfN6annU20CnC4XBsBnJDxHcElLNRMxpXWi5eWefY6E0Fy2b+EDPhGe5u5hoGwLiQIEWrnWYx9qQeAyJDOPBf+XJcXAOHo28xFZ/XCUB1UFnavrDWmjAZ3tthc/Er+tEV03T+71sFKRRytkmLPylKMXvA5ABJQp"
}

resource "aws_autoscaling_group" "demo_asg" {
  launch_configuration = "${aws_launch_configuration.demo_lc.id}"
#  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  availability_zones = ["ap-south-1a"]
  load_balancers    = ["${aws_elb.demo_elb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-demo_asg"
    propagate_at_launch = true
  }
}

resource "aws_elb" "demo_elb" {
  name               = ""
#  availability_zones = ["${data.aws_availability_zones.all.names}"]
  availability_zones = ["ap-south-1a"]
  security_groups    = ["${aws_security_group.demo_elb_sg.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "demo_elb_sg" {
  name = "terraform_demo_elb_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
