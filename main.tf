provider "aws" {
  region  = "ap-southeast-2"
#  profile = "024848461016_cirrus-shared" 
  profile = "cirrus-shared-024848461016"
  
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

data "aws_security_group" "existing" {
  filter {
    name   = "group-name"
    values = ["cirrus-shared-ic-general-interface-endpoints"]    
  }
  vpc_id = "vpc-077612b2dcafd9d44" 
}

data "http" "myip" {
  url = "https://api.ipify.org"
}

/*
resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
  security_group_id = data.aws_security_group.existing.id
  description       = "Allow HTTP traffic on port ${var.server_port} from my current PI"
}
*/

resource "aws_instance" "kyan-ami" {   
  ami      = "ami-0bd143bcbc97ff02d"
  instance_type = "t2.micro"
  vpc_security_group_ids =[data.aws_security_group.existing.id]
  subnet_id ="subnet-044e0a139ddcb43d8"
 # associate_public_ip_address = true


  user_data_base64 = base64encode(<<-EOF
#!/bin/bash
if ! command -v python3 &> /dev/null; then
  if command -v yum &> /dev/null; then
    yum install -y python3
  elif command -v apt-get &> /dev/null; then
    apt-get update && apt-get install -y python3
  fi
fi
echo "Hello, World!" > index.html
nohup python3 -m http.server ${var.server_port} &
EOF
  )
  
 user_data_replace_on_change = true

 tags = { Name = "kyan_tf_1"}  
}
