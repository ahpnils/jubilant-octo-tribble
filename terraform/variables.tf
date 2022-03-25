variable "project" {}

variable "credentials_file" {}

variable "region" {
  default = "us-east1"
}

variable "zone" {
  default = "us-east1-c"
}

variable "subnet_cidr" {
  default = "10.42.0.0/24"
}

variable "ssh_user" {}

variable "ssh_pub_key_file" {}

variable "os_image" {}
