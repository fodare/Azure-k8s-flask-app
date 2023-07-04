# Terraform state stored in a backend.
terraform {
  backend "azurerm" {
    # storage_account_name="<<storage_account_name>>" #OVERRIDE in TERRAFORM init
    # access_key="<<storage_account_key>>" #OVERRIDE in TERRAFORM init
    # key="<<env_name.k8s.tfstate>>" #OVERRIDE in TERRAFORM init
    # container_name="<<storage_account_container_name>>" #OVERRIDE in TERRAFORM init
  }
}

provider "azurerm" {
  //version = "~>2.0.0"
  features {}
}

# Create a resource group for the cluster.
resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resource_group}_${var.environment}"
  location = var.location
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
    vnet_subnet_id = data.azurerm_subnet.kubesubnet.id
    # vm_size         = "standard_d2as_v5"      CHANGE IF AN ERROR ARISES 
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

   network_profile {
    network_plugin     = "azure"
    dns_service_ip     = var.aks_dns_service_ip
    docker_bridge_cidr = var.aks_docker_bridge_cidr
    service_cidr       = var.aks_service_cidr
  }

  tags = {
    Environment = var.environment
  }
  depends_on = [ azurerm_virtual_network.testnetwork, azurerm_application_gateway.appgateway ]
}

# Virtual network
resource "azurerm_virtual_network" "testnetwork"{
  name = var.virtual_network_name
  location = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  address_space = [var.virtual_network_address_prefix]

  subnet {
    name = var.aks_subnet_name
    address_prefix = var.aks_subnet_address_prefix
  }

  subnet {
    name = "appgwsubnet"
    address_prefix = var.app_gateway_subnet_address_prefix
  }

  # tags = var.environment
}


resource "azurerm_public_ip" "publicip" {
  name = "publicip"
  location = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  allocation_method = "Static"
  sku = "Standard"
  tags = {
    enviroment: var.environment
  }
}

data "azurerm_subnet" "appgwsubnet" {
  name                 = "appgwsubnet"
  virtual_network_name = azurerm_virtual_network.testnetwork.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  depends_on           = [azurerm_virtual_network.testnetwork]
}

data "azurerm_subnet" "kubesubnet" {
  name                 = var.aks_subnet_name
  virtual_network_name = azurerm_virtual_network.testnetwork.name
  resource_group_name  = azurerm_resource_group.resource_group.name
  depends_on           = [azurerm_virtual_network.testnetwork]
}


resource "azurerm_application_gateway" "appgateway" {
  name = var.app_gateway_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  sku {
    name = "Standard_Small"
    tier = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name = "appGatewayIpConfig"
    subnet_id = data.azurerm_subnet.appgwsubnet.id
  }

  frontend_port {
    name = "${azurerm_virtual_network.testnetwork.name}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name = "${azurerm_virtual_network.testnetwork.name}-feip"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
  
  # Remove
  # frontend_ip_configuration { 
  #   name = "${azurerm_virtual_network.testnetwork.name}-pr" 
  #   subnet_id = data.azurerm_subnet.appgwsubnet.id
  #   private_ip_address_allocation = "Dynamic" 
  #   } 

  backend_address_pool {
    name = "${azurerm_virtual_network.testnetwork.name}-beap"
  }

  backend_http_settings {
    name = "${azurerm_virtual_network.testnetwork.name}-be-htst"
    cookie_based_affinity = "Disabled"
    port = 80
    path = "/frontendservice/"
    protocol = "Http"
    request_timeout = 1
  }

  http_listener {
    name = "${azurerm_virtual_network.testnetwork.name}-httplstn"
    frontend_ip_configuration_name = "${azurerm_virtual_network.testnetwork.name}-feip"
    frontend_port_name = "${azurerm_virtual_network.testnetwork.name}-feport"
    protocol = "Http"
  }
  
  request_routing_rule {
    name = "${azurerm_virtual_network.testnetwork.name}-rqrt"
    rule_type = "Basic"
    http_listener_name = "${azurerm_virtual_network.testnetwork.name}-httplstn"
    backend_address_pool_name = "${azurerm_virtual_network.testnetwork.name}-beap"
    backend_http_settings_name = "${azurerm_virtual_network.testnetwork.name}-be-htst"
  }
  # tags  = var.environment
  
  depends_on = [ azurerm_virtual_network.testnetwork, azurerm_public_ip.publicip ]
}
