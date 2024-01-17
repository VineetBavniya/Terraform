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



// create deployment template

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "kubernetesdeployment"
    namespace = kubernetes_namespace.pod_namespace.metadata.0.name
    labels = {
      app = "deploymentlabels"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "deploymentlabels"
      }
    }


    template {
      metadata {
        labels = {
          app = "deploymentlabels"
        }
      }

      spec {
        container {
          name = "nginx-container"
          image = "nginx"

          port {
            container_port = 80
          }
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
        app = kubernetes_deployment.deployment.metadata.0.labels.app
    }

    type = "NodePort"

    port {
      node_port = 30123
      port = 80
      target_port = 80
    }
 }
}
