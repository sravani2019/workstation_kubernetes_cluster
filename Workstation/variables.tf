variable "ami_id" {
  type    = string
  default = "ami-0220d79f3f480ecf5"

}

variable "instance_type" {
  type    = string
  default = "t3.micro"
 
}
variable "sg_name" {
  type    = string
  default = "allow_tls"

}

variable "sg_description" {
  type    = string
  default = "Allow TLS inbound traffic and all outbound traffic"
}

variable "cidr_blocks" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "ec2_tags" {
  type = map(any)
  default = {
    Name        = "Docker"
    project     = "practice"
    environment = "dev"
  }
}

