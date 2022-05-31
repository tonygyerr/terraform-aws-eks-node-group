module "eks_managed_node_group" {
  source  = "git::https://github.com/tonygyerr/terraform-aws-eks-node-group.git"

  app_name        = var.app_name
  profile         = var.profile
  region          = var.aws_region
  cluster_name    = "${var.app_name}-my-cluster"
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  min_size     = 1
  max_size     = 10
  desired_size = 1

  instance_types = var.instance_types
  capacity_type  = var.capacity_type
  environment    = var.environment
  vpc_config     = var.vpc_config

  labels = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  taints = {
    dedicated = {
      key    = "dedicated"
      value  = "gpuGroup"
      effect = "NO_SCHEDULE"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}