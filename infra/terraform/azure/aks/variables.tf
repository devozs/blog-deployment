variable "app_name" {
  type        = string
  description = "The root name of the application, as an alphanumeric short value. This name will be used as an affix to create the solution resources on Azure."
}

variable "location" {
  type        = string
  description = "The Azure location on which to create the resources."
  default     = "westeurope"
}

variable "aks_vm_size" {
  description = "Kubernetes VM size."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "aks_namespace" {
  description = "The default namespace to be set on AKS."
  type        = string
  default     = "devozs"
}

variable "aks_node_count" {
  description = "Number of nodes to deploy for Kubernetes"
  type        = number
  default     = 1
}

variable "management_vm_size" {
  description = "Management VM size."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "management_node_count" {
  description = "Number of nodes to deploy for Management"
  type        = number
  default     = 1
}

variable "container_image" {
  type    = string
  default = "ghcr.io/azure/azure-workload-identity/msal-python"
}
