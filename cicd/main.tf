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
    }
  ]
}
