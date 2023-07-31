resource "yandex_compute_instance_group" "node-group-01" {
  name = "node-group-01"
  folder_id = var.yc_folder_id
  service_account_id = var.yc_sa_id
  instance_template {
    platform_id   = "standard-v1"
    boot_disk {
      initialize_params {
        image_id  = data.yandex_compute_image.u2004.id
        type      = "network-nvme"
        size      = 20
      }
    }
    network_interface {
      nat = true
      subnet_ids = [
        yandex_vpc_subnet.private[0].id,
        yandex_vpc_subnet.private[1].id,
        yandex_vpc_subnet.private[2].id
      ]
    }
    resources {
      cores  = local.res.cores[terraform.workspace]
      memory = local.res.memory[terraform.workspace]
    }

    metadata = {
      ssh-keys = "ubuntu:${file(var.ssh_key_pub)}"
    }
  }
  # создаст группу с необходимым количеством ВМ
  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = var.yc_zone
  }

  deploy_policy {
    max_unavailable = 3
    max_creating    = 3
    max_expansion   = 3
    max_deleting    = 3
  }
}
