terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "k8s_iniciativa" {             #vincula com recurso abaixo no campo "cluster_id"
  name   = var.k8s_name
  region = var.region
  version = "1.22.8-do.1"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-4gb"		#alteração 4GB de RAM
    node_count = 2					#QTD de máquinas

  }
}

# Para esse novo recurso preciso vinculá-lo ao cluster ID do kubernetes

resource "digitalocean_kubernetes_node_pool" "node_premium" {
  cluster_id = digitalocean_kubernetes_cluster.k8s_iniciativa.id		      #vincula nessa linha

  name       = "premium"
  size       = "s-4vcpu-8gb"
  node_count = 2

}


variable "do_token" {}
variable "k8s_name" {}
variable "region" {}

# Vai exibir no output  A URL base do servidor de API no nó mestre do Kubernetes. "terraform output"
output "kube_endpoint" {
  value  = digitalocean_kubernetes_cluster.k8s_iniciativa.endpoint
}

resource "local_file" "kube_config" {
    content  = digitalocean_kubernetes_cluster.k8s_iniciativa.kube_config.0.raw_config
    filename = "kube_config.yaml"
}

# ESTOU UTILIZANDO OUTRO PROVIDER, rode "terraform init" antes, depois "terraform apply" o arquivo será obtido localmente