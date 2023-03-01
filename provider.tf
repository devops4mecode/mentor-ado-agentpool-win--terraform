terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.92.0"
    }
  }
}

provider "azurerm" {
  version         = ">= 1.28.0"
  features {}
  subscription_id = "c10e0889-ad39-4d65-b6f0-aac9373ac19f"
}