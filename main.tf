locals {
  tf_address = "https://${var.tf_hostname}/api/v2"
}

resource "tfe_workspace" "test" {
  name         = "variable-set"
  organization = var.tf_organization
}

provider "tfe" {
  token    = var.tf_token
  hostname = var.tf_hostname
}

variable "tf_token" {}
variable "tf_hostname" {}
variable "tf_organization" {}

terraform {
  required_providers {
    tfe = {
      version = "~> 0.27.0"
    }
    restapi = {
      source  = "mastercard/restapi"
      version = "~> 1.16.1"
    }
  }
}

resource "restapi_object" "variable_set" {
  path = "/varsets"

  create_path = "/organizations/ryanwholey/varsets"
  data = jsonencode({
    data = {
      type = "varsets"
      attributes = {
        name        = "test-set"
        description = "A test varset"
        global      = false
      }
    }
  })
}

provider "restapi" {
  uri                  = local.tf_address
  debug                = true
  write_returns_object = true
  id_attribute         = "data/id"

  headers = {
    "Authorization" = "Bearer ${var.tf_token}",
    "Content-Type"  = "application/vnd.api+json"
  }
}
