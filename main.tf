terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 4.0.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_network" "tp3_net" {
  name = "tp3-network"
}

resource "docker_container" "web" {
  name  = "tp3-web"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.tp3_net.name
  }

  ports {
    internal = 80
    external = var.external_port
  }
}
