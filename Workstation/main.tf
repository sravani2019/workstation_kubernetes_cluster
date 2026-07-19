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
 
  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y install dnf-plugins-core",
      "sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo",
      "sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo systemctl enable --now docker",
      "sudo usermod -aG docker ec2-user",
      # Detect system architecture and fetch the corresponding binary
      "ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')",
      "PLATFORM=$(uname -s)_$ARCH",
      "curl -sLO https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz",
      "curl -sL https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt | grep $PLATFORM | sha256sum --check",
      "tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz",
      "sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl",
      "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.34.2/2025-11-13/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "sudo mv kubectl /usr/local/bin/kubectl",

    ]
  }
  
     connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      password = "DevOps321"
      timeout     = "5m"
    }

     tags = var.ec2_tags
  }




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