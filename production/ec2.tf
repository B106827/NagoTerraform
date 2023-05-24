# ---------------------------
# 変数定義
# ---------------------------
locals {
  # Amazon Linux 2 Kernel 5.10 AMI 2.0.20230119.1 x86_64 HVM gp2
  ec2_ami           = "ami-06ee4e2261a4dc5c3"
  ec2_instance_type = "t3.medium"
}

# ---------------------------
# EC2（ap-northeast-1a)
# ---------------------------
resource "aws_instance" "production-1a" {
  ami           = local.ec2_ami
  instance_type = local.ec2_instance_type
  subnet_id     = module.vpc.private_subnets[0]

  vpc_security_group_ids = [
    aws_security_group.allow-app.id,
  ]

  # SSMを利用してSSHする
  iam_instance_profile = aws_iam_instance_profile.private-instance-ssm.name

  # クレジット仕様は「Unlimited」としておく
  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    encrypted             = true
    # EC2終了時に削除
    delete_on_termination = true
  }

  tags = {
    Name = "${local.project_name_env}-production-1a"
  }
  volume_tags = {
    Name = "${local.project_name_env}-production-1a-volume"
  }
}

# ---------------------------
# EC2（ap-northeast-1c)
# ---------------------------
resource "aws_instance" "production-1c" {
  ami           = local.ec2_ami
  instance_type = local.ec2_instance_type
  subnet_id     = module.vpc.private_subnets[1]

  vpc_security_group_ids = [
    aws_security_group.allow-app.id,
  ]

  # SSMを利用してSSHする
  iam_instance_profile = aws_iam_instance_profile.private-instance-ssm.name

  # クレジット仕様は「Unlimited」としておく
  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    volume_size           = 100
    volume_type           = "gp3"
    encrypted             = true
    # EC2終了時に削除
    delete_on_termination = true
  }

  tags = {
    Name = "${local.project_name_env}-production-1c"
  }
  volume_tags = {
    Name = "${local.project_name_env}-production-1c-volume"
  }
}

# ---------------------------
# IAMロール設定
# ---------------------------
# IAMポリシー
data "aws_iam_policy_document" "assume-role" {
  statement {
    # EC2がロールを使用できるようにするためのポリシー
    actions =["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAMロール
resource "aws_iam_role" "private-instance-role" {
  name               = "${local.project_name_env}-private-instance-role"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
  description        = "Private Instance Role"
}

# SSMのポリシーをロールにアタッチ
resource "aws_iam_role_policy_attachment" "private-instance-ssmcore" {
  role       = aws_iam_role.private-instance-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# インスタンスプロファイル
resource "aws_iam_instance_profile" "private-instance-ssm" {
  name = "${local.project_name_env}-private-instance-profile"
  role = aws_iam_role.private-instance-role.name
}