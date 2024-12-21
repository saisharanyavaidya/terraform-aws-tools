# Here we are creating instances for Jenkins using terraform.. we need to install few dependencies after creating instance using .sh fies in user-data, so instead of manual process we are using terraform

module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "jenkins-master"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0fbcae1d2d339bcf4"]
  subnet_id = "subnet-0ce3cdb1524e357ae"
  ami = data.aws_ami.ami_id.id

  #jenkins-master.sh will have all the installations neccessary for Jenkins , userdata will be called only once while creating instance
  user_data = file("jenkins_master.sh")
  
  tags = {
        name = "jenkins-master"
  } 
}

module "jenkins-agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0fbcae1d2d339bcf4"]
  subnet_id = "subnet-0ce3cdb1524e357ae"
  ami = data.aws_ami.ami_id.id
  user_data = file("jenkins-agent.sh")
  
  tags = {
        name = "jenkins-agent"
  } 
}

resource "aws_key_pair" "tools" {
  key_name   = "tools"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ONJth+DzeXbU3oGATxjVmoRjPepdl7sBuPzzQT2Nc sivak@BOOK-I6CR3LQ85Q"
  public_key = file("~/.ssh/tools.pub")
  # ~ means windows home directory
}

module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "nexus"

  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-0fbcae1d2d339bcf4"]
  # convert StringList to list and get first element
  subnet_id = "subnet-0ce3cdb1524e357ae"
  ami = data.aws_ami.nexus_ami_info.id
  key_name = aws_key_pair.tools.key_name
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 30
    }
  ]
  tags = {
    Name = "nexus"
  }
}


module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name
  
  records = [
    {
      name    = "jenkins"
      type    = "A"
      allow_overwrite = true
      ttl = 1
      records = [
        module.jenkins.public_ip
      ]
    },
     {
      name    = "jenkins-agent"
      type    = "A"
      allow_overwrite = true
      ttl = 1
      records = [
        module.jenkins-agent.private_ip
      ]
    },
    {
      name    = "nexus"
      type    = "A"
      ttl     = 1
      allow_overwrite = true
      records = [
        module.nexus.public_ip
      ]
    }
  ]
}
