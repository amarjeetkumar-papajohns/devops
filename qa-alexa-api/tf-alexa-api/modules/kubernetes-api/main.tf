resource "kubernetes_service" "alexa-api-service" {
  metadata {
    name = "alexa-api-service"
  }
  spec {
    selector {
      app = "alexa-api-test"
    }
    port {
      port = 80
      target_port = 8080
    }
    type = "LoadBalancer"
  }
}
resource "kubernetes_config_map" "alexa-config" {
   "metadata" {
       name = "alexa-config"
   }

   data = {
       ENDPOINT_HOST = "alexa-domain-api-service.default.svc.cluster.local"
       ENDPOINT_PORT =  "80"
       ENDPOINT_PROTOCOL = "http"
   }
}


resource "kubernetes_secret" "nginx-ssl" {
  metadata {
    name = "nginx-ssl"
  }

  data {
    "nginx.key" = "${file("nginx.key")}"
    "nginx.crt" = "${file("nginx.crt")}"
  }

  type = "generic"
}

resource "kubernetes_replication_controller" "alexa-api-test" {
  metadata {
    name = "alexa-api-test"
    labels {
      app = "alexa-api-test"
    }
  }

  spec {
    selector {
      app = "alexa-api-test"
    }

    template {
      container {
        image = "gcr.io/endpoints-release/endpoints-runtime:1"
        name = "esp"
        args = ["-p", "8081",  "-a", "127.0.0.1:8080", "-s", "alexa-api.endpoints.orders-dev-pj.cloud.goog","--rollout_strategy","managed"]
        port {
          container_port = "8081"
        }
      }
      container {
      image = "${var.image_base_url}:${var.image_ver}"
      name = "alexa-api-test"

        env{
        name = "ENDPOINT_HOST"
        value = "alexa-domain-api-service.default.svc.cluster.local"
        }
        env {
        name = "ENDPOINT_PROTOCOL"
        value = "http"
        }
        env {
        name = "ENDPOINT_PORT"
        value = "80"
        }
        port {
        container_port = 8080
        }
        volume_mount {
            mount_path = "/etc/nginx/ssl"
            name       = "nginx-ssl"
            read_only  = true
          }
      }
      volume {
              name = "${kubernetes_secret.nginx-ssl.metadata.0.name}"
              secret {
                secret_name = "${kubernetes_secret.nginx-ssl.metadata.0.name}"
              }
            }
    }
  }
}
