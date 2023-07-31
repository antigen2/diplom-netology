resource "yandex_vpc_network" "netology-diplom-network" {
  name = "netology-diplom-network"
}

resource "yandex_vpc_subnet" "private" {
  name            = "private-subnet-${count.index}"
  count           = length(var.yc_zone)
  network_id      = yandex_vpc_network.netology-diplom-network.id
  v4_cidr_blocks  = var.private_ip[count.index]
  zone            = var.yc_zone[count.index]
}
