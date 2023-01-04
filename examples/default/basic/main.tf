module "main_module" {
  source     = "../../../modules/default"
  is_enabled = var.is_enabled
  aws_org_config = {
    aws_accounts = [{
      name   = "account1",
      prefix = "prefix1",
      email  = "email1@domain1.com"
      },
      {
        name   = "account2",
        prefix = "prefix2",
        email  = "email2@domain2.com"
      }
    ]
  }
  aws_region = var.aws_region
}
