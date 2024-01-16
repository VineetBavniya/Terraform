// Create pod 
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
      name = "podnames" // name of namespace 
    }
  
}



resource "kubernetes_pod_v1" "pod" { 
    metadata {
      name = "pod"
      namespace = kubernetes_namespace.pod_namespace.metadata.0.name
      // namespace access name space here  
      labels = { // create lebels 
        app = "pod_labels" // defined name for labesl
      }
      
    }

    spec { 
        container { 
            image = "nginx" // container images 
            name = "nginx" // container images name 
            
            port {
                 container_port = 80 // container port number define 
            }
        }
      }
  
}

// create pod service

resource "kubernetes_service" "pod_service" {
  metadata {
    name = "podsservice"
    namespace = kubernetes_namespace.pod_namespace.metadata.0.name // access names space here 
  }

 spec {
    selector = {
        app = kubernetes_pod_v1.pod.metadata.0.labels.app // access here lables 
    }

    type = "NodePort"  // define Port type 
  
    port {
      node_port = 30123
      port = 80
      target_port = 80
    }
 }
}
