terraform {
        backend "gcs" {
        project = "dev-orders"
        bucket  = "devops-qa-alexa-api"
        prefix  = "devops-cd-tfstate"
        }
}

provider "google" {
  credentials = "${file("prod-cicd-infrastructure-467ab13eef50.json")}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}



provider "kubernetes" {
  host = "${module.gce-cluster.name}"
  username = "${module.gce-cluster.username}"
  password = "${module.gce-cluster.password}"
  client_certificate = "${module.gce-cluster.client_certificate}"
  client_key = "${module.gce-cluster.client_key}"
  cluster_ca_certificate = "${module.gce-cluster.cluster_ca_certificate}"
}


module "gce-cluster" {
    source = "modules/gce-infra/"
    project_id    = "${var.project_id}"
    #cluster_name  = "${var.cluster_name}"
    zone          = "${var.zone}"
    #additional_zone1 = "${var.additional_zone1}"
    #additional_zone2 = "${var.additional_zone2}"
    #label         = "${var.label}"
    #tag           = "${var.tag}"
}

module "order-api" {
    source = "modules/kubernetes-api"
    project_id      = "${var.project_id}"
    #k8_service_name = "${var.k8_service_name}"
    #k8_rc_name      = "${var.k8_rc_name}"
    #k8_app_name     = "${var.k8_app_name}"
    image_base_url  = "${var.image_base_url}"
    image_ver       = "${var.image_ver}"
}
