provider "aws" {
  profile = "plrl-sandbox" # Change or remove this line if you're not using a named profile
  region  = "us-east-2"
}

# Generate a human-readable unique ID for suffixes
resource "random_pet" "unique" {
  length    = 3
  separator = "-"
}

# Create an SSH key pair
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "ansible-ssh-key-${random_pet.unique.id}"
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./ansible-ssh-key-${random_pet.unique.id}.pem"
  }

  provisioner "local-exec" {
    command = "chmod 400 ./ansible-ssh-key-${random_pet.unique.id}.pem"
  }
}

# Store the SSH private key in SSM Parameter Store
resource "aws_ssm_parameter" "ssh_private_key" {
  name        = "/ansible/ssh-private-key-${random_pet.unique.id}"
  description = "Private SSH key for Ansible hosts"
  type        = "SecureString"
  value       = tls_private_key.pk.private_key_pem
}

# Create a security group within the specified VPC
resource "aws_security_group" "allow_ssh" {
  name_prefix = "allow_ssh"
  vpc_id      = "vpc-0e1f868e9a7642b49" # `Plural` VPC where the `boot-test` eks nodes reside

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
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

# Create three EC2 instances for Ansible hosts within the specified subnet
resource "aws_instance" "ansible_hosts" {
  count                       = 3
  ami                         = "ami-0fe21a9f6922d5c6a" # Ubuntu 24.04 LTS
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.kp.key_name
  subnet_id                   = "subnet-04a115c2c274d6260" # plural-public-us-east-2a
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "AnsibleHost-${count.index + 1}-${random_pet.unique.id}"
  }
}

# Outputs
output "ansible_instance_ids" {
  value = [for instance in aws_instance.ansible_hosts : instance.id]
}

output "ansible_instance_public_ips" {
  value = [for instance in aws_instance.ansible_hosts : instance.public_ip]
}

output "ansible_key_pair_name" {
  value = aws_key_pair.kp.key_name
}

output "ssh_private_key_ssm_parameter" {
  value = aws_ssm_parameter.ssh_private_key.name
}
