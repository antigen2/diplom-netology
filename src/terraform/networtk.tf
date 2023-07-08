resource "yandex_vpc_network" "netology-diplom-network" {
  name = "netology-diplom-network"
}

resource "yandex_vpc_subnet" "public" {
  name            = "public-subnet"
  network_id      = yandex_vpc_network.netology-diplom-network.id
  v4_cidr_blocks  = var.public_ip[0]
  zone = var.yc_zone[0]
}

resource "yandex_vpc_subnet" "private" {
  name            = "private-subnet-${count.index}"
  count           = length(var.yc_zone)
  network_id      = yandex_vpc_network.netology-diplom-network.id
  v4_cidr_blocks  = var.private_ip[count.index]
  route_table_id  = yandex_vpc_route_table.route-01.id
  zone            = var.yc_zone[count.index]
}

resource "yandex_vpc_route_table" "route-01" {
  name       = "nat-gateway"
  network_id = yandex_vpc_network.netology-diplom-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}
