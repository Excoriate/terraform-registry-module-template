module "main_module" {
  source     = "../../../modules/default"
  is_enabled = var.is_enabled

  tags = {
    environment = "development"
    project     = "terraform-module-template"
    managed-by  = "terraform"
  }
}
