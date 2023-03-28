terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
 #   random = {
 #   source  = "hashicorp/random"
 #   version = "3.4.3"
 #   }
  }
 ##  cloud {
  #  organization = "1212-zzl"

    #workspaces {
     # name = "aws-git-automate"
    #}
  }
#}
provider "aws" {
  region = "ap-southeast-1"
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "RG01" {
  name     = "ZZL-RG01"
  location = "Southeast Asia"
}
