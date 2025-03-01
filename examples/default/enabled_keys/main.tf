module "main_module" {
  source     = "../../../modules/default"
  is_enabled = true

  tags = {
    Environment = "production"
    Terraform   = "true"
    Module      = "default"
  }
}
