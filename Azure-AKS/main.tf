# Create a resource group where the cluster.
resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resource_group}_${var.environment}"
  location = var.location
}

provider "azurerm" {
  //version = "~>2.0.0"
  features {}
}

#  Create cluster
resource "azurerm_kubernetes_cluster" "terraform-k8s" {
  name                = "${var.cluster_name}_${var.environment}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = var.dns_prefix

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  default_node_pool {
    name       = "agentpool"
    node_count = var.node_count
    vm_size    = "standard_b2ms"
    # vm_size         = "standard_d2as_v5"      CHANGE IF AN ERROR ARISES 
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    Environment = var.environment
  }
}

# Ingress configuration
# resource "kubernetes_ingress_v1" "defaultingres" {
#   metadata {
#     name      = "test-ingress"
#     namespace = "default"
#     annotations = {
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"
#     }
#   }
#   spec {
#     rule {
#       http {
#         path {
#           path = "/frontendservice/*"
#           backend {
#             service {
#               name = "frontendservice"
#               port {
#                 number = 5000
#               }
#             }
#           }
#         }
#         path {
#           path = "/backendservice/*"
#           backend {
#             service {
#               name = "backendservice"
#               port {
#                 number = 5001
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

# Terraform state stored in a backend.
terraform {
  backend "azurerm" {
    # storage_account_name="<<storage_account_name>>" #OVERRIDE in TERRAFORM init
    # access_key="<<storage_account_key>>" #OVERRIDE in TERRAFORM init
    # key="<<env_name.k8s.tfstate>>" #OVERRIDE in TERRAFORM init
    # container_name="<<storage_account_container_name>>" #OVERRIDE in TERRAFORM init
  }
}
