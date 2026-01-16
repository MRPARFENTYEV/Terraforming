resource "yandex_compute_instance" "web" {
  count = 2

  name = "web-${count.index + 1}"

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.example.id
    ]
  }

 boot_disk {
    initialize_params {
      image_id = var.image_id  # например, Ubuntu 22.04
      size     = 10
    }
  }

  resources {
    cores  = 2
    memory = 2
  }
}