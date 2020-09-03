resource "kubernetes_deployment" "prom_deploy" {

  metadata {
    name      = "wordpress-deplyment"
    namespace = "default"
    labels = {
      server = "web"
    }
  }

  spec {
    selector {
      match_labels = {
        server = "web"
      }
    }

    template {
      metadata {
        labels = {
          server = "web"
        }
      }

      spec {
        container {
          image = "wordpress"
          name  = "wordpress"
          env {
            name  = "WORDPRESS_DB_HOST"
            value = "${aws_db_instance.default.endpoint}"
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value = "wordpressdb"
          }
          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = "password"
          }
          env {
            name  = "WORDPRESS_DB_NAME"
            value = "wordpressdb"
          }
          port {
            container_port = 80
          }

        }
      }
    }
  }
}

# service 

resource "kubernetes_service" "prom_svc" {

  metadata {
    name      = "wordpress"
    namespace = "default"
  }
  spec {
    selector = {
      server = "web"
    }
    port {
      port        = 80
      # node_port   = 31003
    }
    type = "NodePort"
  }
}
