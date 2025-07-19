module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "auto-deploy-eks"
  cluster_version = "1.28"

  subnet_ids = module.vpc.public_subnets
  vpc_id     = module.vpc.vpc_id

  enable_irsa                    = true
  manage_aws_auth_configmap      = true

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.medium"]

      tags = {
        Name = "auto-deploy-ng"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
