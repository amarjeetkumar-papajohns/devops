resource "google_container_cluster" "primary" {
  project = "${var.project_id}"  
  name    = "alexa-devops-deploy"
  zone    = "${var.zone}"
  initial_node_count = 1

  additional_zones = [
    "us-central1-b",
    "us-central1-c",
  ]


  node_config {
    oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/trace.append"    
]

    labels {
      Name = "minion"
    }

    tags = ["testcluster"]
  }
}

