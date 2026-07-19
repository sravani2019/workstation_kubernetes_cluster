resource "aws_instance" "workstation" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.kubernetes.id]
  iam_instance_profile = aws_iam_instance_profile.kubernetes.name
  user_data = templatefile("${path.module}/user.sh.tftpl", {
    partition_number = 4
    extend_size = 30
  })
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    delete_on_termination = true
  
  }
  tags = {
    Name = "workstation"
  }
}
  #  provisioner "remote-exec" {
    
   

  #  }
  
  #    connection {
  #     type        = "ssh"
  #     host        = self.public_ip
  #     user        = "ec2-user"
  #     password = "DevOps321"
  #     timeout     = "5m"
  #   }

  #    tags = var.ec2_tags
  # }




resource "aws_security_group" "kubernetes" {
  name        = var.sg_name
  description = var.sg_description
  #vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }




  tags = var.ec2_tags

}