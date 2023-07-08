terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token		= var.yc_token
  cloud_id	= var.yc_cloud_id
  folder_id	= var.yc_folder_id
}

# Образ
data "yandex_compute_image" "u2004" {
  family = "ubuntu-2004-lts"
}
