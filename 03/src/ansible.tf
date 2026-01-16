locals {
  web_hosts = [
    for vm in yandex_compute_instance.web : {
      name = vm.name
      ip   = vm.network_interface[0].nat_ip_address
      fqdn = vm.fqdn
    }
  ]

  db_hosts = [
    for vm in yandex_compute_instance.db : {
      name = vm.name
      ip   = vm.network_interface[0].nat_ip_address
      fqdn = vm.fqdn
    }
  ]

  storage_hosts = [
    {
      name = yandex_compute_instance.storage.name
      ip   = yandex_compute_instance.storage.network_interface[0].nat_ip_address
      fqdn = yandex_compute_instance.storage.fqdn
    }
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
