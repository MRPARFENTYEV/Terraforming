locals {
  vm_web_name = "${var.vpc_name}-${var.default_zone}-web"
  vm_db_name  = "${var.vpc_name}-${var.vm_db_zone}-db"
}