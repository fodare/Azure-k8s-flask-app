variable "client_id" {}
variable "client_secret" {}
variable "ssh_public_key" {}

variable "environment" {
  default = "dev"
}

variable "location" {
  default = "northeurope"
}

variable "node_count" {
  default = 2
}

variable "dns_prefix" {
  default = "k8stest"
}

variable "cluster_name" {
  default = "k8stest"
}

variable "resource_group" {
  default = "kubernetes"
}


# Ingress configuration start here

variable "virtual_network_name" {
  description = "Virtual network name"
  default = "aksVirtualNetwork"
}

variable "virtual_network_address_prefix" {
  description = "VNET address prefix"
  default     = "192.168.0.0/16"
}

variable "aks_subnet_name" {
  description = "Subnet Name."
  default     = "kubesubnet"
}

variable "aks_subnet_address_prefix" {
  description = "Subnet address prefix."
  default     = "192.168.0.0/24"
}

variable "app_gateway_subnet_address_prefix" {
  description = "Subnet server IP address."
  default     = "192.168.1.0/24"
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway"
  default     = "ApplicationGatewayDev"
}

variable "app_gateway_sku" {
  description = "Name of the Application Gateway SKU"
  default     = "Standard_Small"
}

variable "aks_dns_service_ip" {
  description = "DNS server IP address"
  default     = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
  description = "CIDR notation IP for Docker bridge."
  default     = "172.17.0.1/16"
}

variable "aks_service_cidr" {
  description = "CIDR notation IP range from which to assign service cluster IPs"
  default     = "10.0.0.0/16"
}