resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = var.yc_zone[0]

  resources {
    cores   = 2
    memory  = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.110.254"
    nat        = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_pub)}"
  }
}

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
      nat = false
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
