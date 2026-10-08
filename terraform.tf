terraform {
  required_version = "~> 1.16"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.8"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
  # No backend block: the state file stays on your laptop (terraform.tfstate).
}

provider "azurerm" {
  features {}
  subscription_id = "e01d7df5-1ecb-4abe-98d3-0357f2637147" # the course subscription

  resource_provider_registrations = "none" # the trainers registered Microsoft.Storage once; skipping this makes init faster
  storage_use_azuread             = true   # log in to storage with your Azure account, not with storage keys
}
