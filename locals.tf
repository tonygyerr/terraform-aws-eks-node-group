locals {
  security_group_name   = coalesce(var.security_group_name, "${var.name}-eks-node-group")
  create_security_group = var.create && var.create_security_group
}

locals {
  launch_template_name = try(aws_launch_template.this[0].name, var.launch_template_name, null)
  launch_template_version = coalesce(var.launch_template_version, try(aws_launch_template.this[0].default_version, "$Default"))
}

locals {
  iam_role_name = coalesce(var.iam_role_name, "${var.name}-eks-node-group")

  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  cni_policy = var.cluster_ip_family == "ipv6" ? "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/AmazonEKS_CNI_IPv6_Policy" : "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
}

locals {
  # There are 4 scenarios here that have to be considered for `use_custom_launch_template`:
  # 1. `var.create_launch_template = false && var.launch_template_name == ""` => EKS MNG will use its own default LT
  # 2. `var.create_launch_template = false && var.launch_template_name == "something"` => User provided custom LT will be used
  # 3. `var.create_launch_template = true && var.launch_template_name == ""` => Custom LT will be used, module will provide a default name
  # 4. `var.create_launch_template = true && var.launch_template_name == "something"` => Custom LT will be used, LT name is provided by user
  use_custom_launch_template = var.create_launch_template || var.launch_template_name != ""

  launch_template_name_int = coalesce(var.launch_template_name, "${var.name}-eks-node-group")

  security_group_ids = compact(concat([try(aws_security_group.this[0].id, ""), var.cluster_primary_security_group_id], var.vpc_security_group_ids))
}