terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id   = "fd311764-61f2-43c7-8578-386dbd9785f0"
  tenant_id         = "4af6c951-81a2-4286-b6f3-4e1db39d5b1f"
  client_id         = "f1fb3915-d74a-4da8-8df7-1777c4cbb078"
  client_secret     = "j3A8Q~COrHTPIX9gEwEnCWYsrA7SndGeKYjHZbI4"}