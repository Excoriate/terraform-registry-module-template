module "main_module" {
  source     = "../../../modules/default"
  is_enabled = false

  tags = {
    Environment = "development"
    Terraform   = "true"
    Module      = "default"
  }
}
