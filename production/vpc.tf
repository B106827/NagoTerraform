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

# ----------------------------------------
# VPC/Subnet/RTB/IGW/NatGW/ACL/DefaultSG
# ----------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"
  name    = "${local.project_name_env}-vpc"

  cidr            = local.vpc_cidr_block
  azs             = local.az_list
  public_subnets  = local.public_cidr_list
  private_subnets = local.private_cidr_list

  # DNSホスト名の有効化
  enable_dns_hostnames = true
  # DNS解決の有効化
  enable_dns_support   = true

  enable_nat_gateway = true
  # public_subnetsの最初のサブネットに1つ設置される
  single_nat_gateway = true

  # デフォルト SG
  manage_default_security_group  = true
  default_security_group_name    = "${local.project_name_env}-default-sg"
  default_security_group_ingress = [{
    self       = true
    fromt_port = 0
    to_port    = 0
    protocol   = "-1"
  }]
  default_security_group_egress = [{
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }]
  # デフォルト ACL
  manage_default_network_acl  = true
  default_network_acl_name    = "${local.project_name_env}-default-acl"
  default_network_acl_ingress = [{
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }]
  default_network_acl_egress = [{
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    protocol   = "-1"
    rule_no    = 100
    to_port    = 0
  }]

  # タグ
  tags = {
    Name = "${local.project_name_env}"
  }
  vpc_tags = {
    Name = "${local.project_name_env}-vpc"
  }
  public_subnet_tags = {
    Name = "${local.project_name_env}-public-subnet"
  }
  private_subnet_tags = {
    Name = "${local.project_name_env}-private-subnet"
  }
  default_route_table_tags = {
    Name = "${local.project_name_env}-default-rtb"
  }
  default_network_acl_tags = {
    Name = "${local.project_name_env}-default-acl"
  }
  default_security_group_tags = {
    Name = "${local.project_name_env}-default-sg"
  }
  nat_eip_tags = {
    Name = "${local.project_name_env}-nat-eip"
  }
  igw_tags = {
    Name = "${local.project_name_env}-igw"
  }
  nat_gateway_tags = {
    Name = "${local.project_name_env}-natgw"
  }
  private_route_table_tags = {
    Name = "${local.project_name_env}-private-rtb"
  }
  public_route_table_tags = {
    Name = "${local.project_name_env}-public-rtb"
  }
}

# ---------------------------
# デフォルトルートテーブル
# ---------------------------
resource "aws_default_route_table" "default-rtb" {
  default_route_table_id = module.vpc.default_route_table_id
  tags = {
    Name = "${local.project_name_env}-default-rtb"
  }
}
