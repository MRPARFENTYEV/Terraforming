locals {
  web_hosts = [
    for vm in yandex_compute_instance.web :
    vm.network_interface[0].nat_ip_address
  ]

  db_hosts = [
    for vm in yandex_compute_instance.db :
    vm.network_interface[0].ip_address
  ]

  storage_hosts = [
    yandex_compute_instance.storage.network_interface[0].nat_ip_address
  ]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"

  content = templatefile("${path.module}/inventory.tftpl", {
    web     = local.web_hosts
    db      = local.db_hosts
    storage = local.storage_hosts
  })
}
