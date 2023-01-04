module "main_module" {
  source     = "../../../modules/default"
  is_enabled = var.is_enabled
  aws_region = var.aws_region
}
