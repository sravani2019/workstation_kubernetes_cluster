resource "aws_instance" "workstation" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.kubernetes.id]
 # iam_instance_profile = aws_iam_instance_profile.kubernetes.name
  user_data = templatefile("${path.module}/user.sh.tftpl", {
    partition_number = 4
    extend_size = 30
    aws_access_key   = var.aws_access_key
    aws_secret_key   = var.aws_secret_key
    aws_region           = "us-east-1"
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
resource "terraform_data" "cluster" {

  # depends_on = [
  #   aws_iam_role_policy_attachment.kubernetes
  # ]

  triggers_replace = aws_instance.workstation.id

  input = {
    public_ip = aws_instance.workstation.public_ip
  }

  connection {
    type     = "ssh"
    host     = self.input.public_ip
    user     = "ec2-user"
    password = "DevOps321"
    timeout  = "5m"
  }

  provisioner "remote-exec" {
  when = destroy

  inline = [
    
    #"/usr/local/bin/eksctl delete cluster --name roboshop-devops --region us-east-1 --wait || true",

    #"aws cloudformation delete-stack --stack-name eksctl-roboshop-devops-cluster --deletion-mode FORCE_DELETE_STACK || true"
    "eksctl delete cluster -f /home/ec2-user/eksctl-cluster-creation/eksctl.yaml --wait"
  ]
}
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