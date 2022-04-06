# Using a single workspace:
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cisco-dcn-ecosystem"
    workspaces {
      name = "jristain-app-test"
    }
  }
}

