locals {


  ansible_template = templatefile(
    "${path.module}/templates/ansible_inventory_template.tpl",
    {
      manager_user   = var.useros
      manager_ipaddr = module.swarm_manager.external_ip_address_server[0]
      manager_name   = module.swarm_manager.hostname_server
      worker_user    = var.useros
      worker_ipaddr  = [module.swarm_workers["001"].external_ip_address_server[0], module.swarm_workers["002"].external_ip_address_server[0]]
      worker_name    = [module.swarm_workers["001"].hostname_server, module.swarm_workers["002"].hostname_server]
      worker_index   = [0, 1]
    }
  )
}