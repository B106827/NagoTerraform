# ---------------------------
# 変数定義
# ---------------------------
locals {
  vpc_cidr_block = "10.0.0.0/16"

  # AZ
  az_list = ["ap-northeast-1a", "ap-northeast-1c"]

  # public subnet用CIDR
  public_cidr_list = [
    # 10.0.1.0/24
    cidrsubnet(local.vpc_cidr_block, 8, 1),
    # 10.0.2.0/24
    cidrsubnet(local.vpc_cidr_block, 8, 2),
  ]

  # private subnet用CIDR
  private_cidr_list = [
    # 10.0.101.0/24
    cidrsubnet(local.vpc_cidr_block, 8, 101),
    # 10.0.102.0/24
    cidrsubnet(local.vpc_cidr_block, 8, 102),
  ]
}

# ---------------------------
# VPC/Subnet/IGW/RouteTable/NatGW/VPCEndpoint
# ---------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"
  name    = "${local.project_name_env}-vpc"

  cidr            = local.vpc_cidr_block
  azs             = local.az_list
  public_subnets  = local.public_cidr_list
  private_subnets = local.private_cidr_list

  enable_nat_gateway = true
  # public_subnetsの最初のサブネットに1つ設置される
  single_nat_gateway = true

  # VPC endpoint for S3
  enable_s3_endpoint = true

  tags = {
    env = local.project_env
  }
  vpc_tags = {
    Name = local.project_name_env
  }
}
