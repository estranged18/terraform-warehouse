# ________________________________EC2 INSTANCE________________________________
resource "aws_instance" "terraform_wrs_dev" {
  ami                    = "${var.instance_ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.wrs_public_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.wrs_sg.id}"]
  iam_instance_profile   = "AWSEC2InstanceAccessToS3Role"

    user_data = <<HEREDOC
      #!/bin/bash
      #
      ###############################################################################
      ##                                                                           ##
      ##   Provision the Spring Boot application                                   ##
      ##   Adapted from the following blog post:                                   ##
      ##   http://zoltanaltfatter.com/2016/12/17/spring-boot-application-on-ec2/   ##
      ##                                                                           ##
      ###############################################################################
      #
      # installo java per amazon linux 2
      sudo yum install java-11-amazon-corretto

      mkdir /home/ec2-user/workspace
      cd /etc/systemd/system
      wget https://tfs3bucket.s3.eu-west-1.amazonaws.com/wrs.service

      # give ec2-user write permission to workspace
      # 777 means all permissions
      cd /home/ec2-user
      sudo chmod 777 workspace

      cd /home/ec2-user/workspace
      wget https://tfs3bucket.s3.eu-west-1.amazonaws.com/warehouse-0.0.7-SNAPSHOT.jar
      wget https://tfs3bucket.s3.eu-west-1.amazonaws.com/script.sh

      sudo chmod 777 script.sh

      # start wrs.service
      sudo systemctl daemon-reload
      sudo systemctl enable wrs.service
      sudo systemctl start wrs
    HEREDOC

  tags = {
    Name        = "terraform-wrs-dev"
    Environment = "${var.environment_tag}"
  }  
}
