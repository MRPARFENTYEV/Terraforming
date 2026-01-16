resource "yandex_compute_disk" "data" {
  count = 3

  name = "data-disk-${count.index + 1}"
  size = 1

  zone = var.default_zone
  type = "network-hdd"
}

resource "yandex_compute_instance" "storage" {
  name = "storage"
  zone = var.default_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.data

    content {
      disk_id = secondary_disk.value.id
    }
  }
}