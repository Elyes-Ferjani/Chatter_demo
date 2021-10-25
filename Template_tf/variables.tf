
variable "internet_fc_sg" {
  description = "Open HTTP 80, TCP 8080, SSH 22"
  default     = "#"
}

variable "intranet_sg" {
  description = "Open HTTP 80, TCP 5000, SSH 22"
  default     = "#"
}

variable "elb_sg" {
  description = "Open HTTP 80, TCP 8080, SSH 22"
  default     = "#"
}

variable "public_subnet" {
  default = "#"
}

variable "public_subnet_2" {
  default = "#"
}

variable "private_subnet" {
  default = "#"
}

variable "private_subnet_2" {
  default = "#"
}

variable "key_pair_name" {
  default = "#"
}

variable "vpc_id"{
  default = "#"
}

variable "chatter_ui_ami"{
  default = "#"
}

variable "chatter_api_ami"{
  default = "#"
}

variable "elastic_ip"{
  default = "#"
}

variable "main_rt"{
  default = "#"
}

variable "private_rt"{
  default = "#"
}
