# Here we are creating instances for docker using terraform.. we need to install few dependencies after creating instance using .sh fies in user-data, so instead of manual process we are using terraform

module "docker" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  name = "docker"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0fbcae1d2d339bcf4"]
  subnet_id = "subnet-0ce3cdb1524e357ae"
  ami = data.aws_ami.ami_id.id

  #docker will have all the installations neccessary for docker , userdata will be called only once while creating instance
  user_data = file("docker.sh")
  
  tags = {
        name = "docker"
  } 
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name
  
  records = [
    {
      name    = "docker"
      type    = "A"
      allow_overwrite = true
      ttl = 1
      records = [
        module.docker.public_ip
      ]
    }  ]
}
