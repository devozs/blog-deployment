terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.9.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.22.0"
    }
  }
  backend "azurerm" {}
  #  backend "local" {
  #    path = "./.workspace/terraform.tfstate"
  #  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
### Local Variables
locals {
  app_name               = var.app_name
  aks_namespace          = var.aks_namespace
  aks_node_count         = var.aks_node_count
  aks_vm_size            = var.aks_vm_size
  management_node_count  = var.management_node_count
  management_vm_size     = var.management_vm_size

}


### Resource Group

resource "azurerm_resource_group" "default" {
  name     = "rg-k8s-${local.app_name}"
  location = var.location
}


### Kubernetes Cluster

resource "azurerm_kubernetes_cluster" "default" {
  name                = "aks-${local.app_name}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  dns_prefix          = "aks-${local.app_name}"
  node_resource_group = "rg-resources-${local.app_name}"
#  kubernetes_version = "1.21.9"

  oidc_issuer_enabled = true
#  role_based_access_control_enabled = true
  network_profile {
    network_plugin = "azure"
  }

  default_node_pool {
    name       = "system"
    node_count = local.aks_node_count
    vm_size    = local.aks_vm_size
    max_pods = 50
    only_critical_addons_enabled = true
    tags = {
      Environment = "SystemNode"
    }
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "management" {
  name                  = "management"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.default.id
  node_count            = local.management_node_count
  vm_size               = local.management_vm_size
  max_pods = 110
  mode = "User"
  tags = {
    Environment = "UserNode"
    Type = "Management"
  }
}

resource kubernetes_namespace "devozs"{
  metadata {
    name = local.aks_namespace
  }
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.default.kube_config[0].host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate)
}


