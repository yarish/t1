variable "ami" {
  type = "map"

  default = {
    "ap-south-1" = "ami-07d40e643a23a9813"
    "ap-southeast-1" = "ami-006fctol625b177f"
  }
}

variable "region" {
  default = "ap-south-1"
}

variable "instance_count" {
  default = "2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "aws_region" {
  default = "ap-south-1"
}

variable "batch" {
  default = "5AM"
}

variable "name" {
  default = "terraform-multiple-servers"
}

variable "ssh_key_name" {
    default = "demo_key_1"
}

variable "pub_key" {
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGuCugFDxQfmM9LIeP6TOOh8sKUBbsduEvLzNeKhiLGZNoSg8sdRGOkp9jOWelIIW5jxDk9PB7dT49zEgk29OzRI8VyTKDYVx49H15hEmtITKWNrhpWu7VmmUr0h2E7aJ/0R7F1ybketIqmwq/EK8yNIjtLIv+PS9B0GiW7K1CZyg3jS7qB2IDxlfN6annU20CnC4XBsBnJDxHcElLNRMxpXWi5eWefY6E0Fy2b+EDPhGe5u5hoGwLiQIEWrnWYx9qQeAyJDOPBf+XJcXAOHo28xFZ/XCUB1UFnavrDWmjAZ3tthc/Er+tEV03T+71sFKRRytkmLPylKMXvA5ABJQp"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = string
  default     = ""
}