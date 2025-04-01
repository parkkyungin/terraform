data "aws_ami" "amz2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.amz2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name      = "my-ssh-key" # 미리 생성된 키 페어

  user_data = <<-EOF
        #!/bin/bash
        TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
        yum update -y
        yum install -y httpd
        systemctl start httpd
        systemctl enable httpd
        INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
        echo "<html><body><h1>My EC2 Instance: $INSTANCE_ID</h1></body></html>" > /var/www/html/index.html
EOF

tags = {
    Name = "my-ec2-instance"
  }
}
