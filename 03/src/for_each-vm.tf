# resource "yandex_compute_instance" "db" {
#   for_each = local.db_vms
#
#   name = "db-${each.key}"
#
#   resources {
#     cores  = each.value.cpu
#     memory = each.value.ram
#   }
#
#   boot_disk {
#     initialize_params {
#       size = each.value.disk_volume
#       image_id = var.image_id
#     }
#   }
#
#   network_interface {
#     subnet_id          = yandex_vpc_subnet.develop.id
#     nat                = false
#     security_group_ids = [
#       yandex_vpc_security_group.example.id
#     ]
#   }
#
#   metadata = {
#     ssh-keys = "ubuntu:${local.ssh_key}"
#   }
#
#   depends_on = [
#     yandex_compute_instance.web
#   ]
# }
#
# locals {
#   db_vms = {
#     main = {
#       vm_name     = "main"
#       cpu         = 2
#       ram         = 4
#       disk_volume = 30
#     }
#     replica = {
#       vm_name     = "replica"
#       cpu         = 1
#       ram         = 2
#       disk_volume = 20
#     }
# }
# }
# locals {
#   db_vms = {
#     main    = { vm_name="main", cpu=2, ram=4, disk_volume=30 }
#     replica = { vm_name="replica", cpu=1, ram=2, disk_volume=20 }
#   }
#
#   ssh_key = file("~/.ssh/id_rsa.pub")
# }

resource "yandex_compute_instance" "db" {
  for_each = { for vm in var.each_vm : vm.vm_name => vm }

  name = "db-${each.key}"

  resources {
    cores  = each.value.cpu
    memory = each.value.ram
  }

  boot_disk {
    initialize_params {
      size     = each.value.disk_volume
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.ssh_key}"
  }

  depends_on = [
    yandex_compute_instance.web
  ]
}
locals {
  ssh_key = file("authorized_key.json")
}