// create replicaset 
// Create ReplicaSet 
// provider for kuber 
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  
}


// create namespace for pod

resource "kubernetes_namespace" "pod_namespace" {
    metadata {
      name = "podnames"
    }
  
}

// Create ReplicaSet here 

resource "kubernetes_replication_controller_v1" "replication_controller" {
  metadata {
    name = "replicaset"
    namespace = kubernetes_namespace.pod_namespace.metadata.0.name
    labels = {
      app = "pod_labels"
    }
  }

  spec{
    replicas = 3
    selector = {
      app = "pod_lables"
    }

    template {
      metadata {
        labels = {
          app = "pod_lables"
        }
      }


      spec {
        container {
          name = "nginx"
          image = "nginx"
        }
      }
    }

  }
}


// create pod service

resource "kubernetes_service" "pod_service" {
  metadata {
    name = "podsservice"
    namespace = kubernetes_namespace.pod_namespace.metadata.0.name
  }

 spec {
    selector = {
        app = kubernetes_replication_controller_v1.replication_controller.metadata.0.labels.app
    }

    type = "NodePort"

    port {
      node_port = 30123
      port = 80
      target_port = 80
    }
 }
}

