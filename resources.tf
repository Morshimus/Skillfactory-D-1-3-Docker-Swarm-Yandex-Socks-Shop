#########Network####################################

resource "yandex_vpc_network" "morsh-network" {
  name = var.network_name_yandex

}



resource "yandex_vpc_subnet" "morsh-subnet-a" {
  name           = var.subnet_a_name_yandex
  description    = var.subnet_a_description_yandex
  v4_cidr_blocks = var.subnet_a_v4_cidr_blocks_yandex
  zone           = var.zone_yandex_a
  network_id     = yandex_vpc_network.morsh-network.id

}

resource "yandex_vpc_address" "morsh-addr-pub_1" {
  name = var.name_pubipv4_addr_1
  external_ipv4_address {
    zone_id = var.zone_yandex_a
  }
}


resource "yandex_vpc_address" "morsh-addr-pub_2" {
  name = var.name_pubipv4_addr_2
  external_ipv4_address {
    zone_id = var.zone_yandex_a
  }
}


resource "yandex_vpc_address" "morsh-addr-pub_3" {
  name = var.name_pubipv4_addr_3
  external_ipv4_address {
    zone_id = var.zone_yandex_a
  }
}


################## Compute Instance Resources #################################################################

module "swarm_manager" {
  source = "git::https://github.com/Morshimus/yandex-cloud-instance-module?ref=tags/1.0.0"

  prefix = "swarm-mgmt"

  postfix = "001"

  source_image_family = "ubuntu-2204-lts"

  boot_disk = {
    initialize_params = {
      size = var.os_disk_size
      type = "network-ssd"
    }
  }

  network_interface = [
    {
      subnet_id      = yandex_vpc_subnet.morsh-subnet-a.id
      nat            = true
      nat_ip_address = yandex_vpc_address.morsh-addr-pub_1.external_ipv4_address[0].address
    }
  ]

  vm_vcpu_qty = 2
  vm_ram_qty  = 2
  adm_pub_key = tls_private_key.key.public_key_openssh
  useros      = var.useros
}

module "swarm_workers" {
  source = "git::https://github.com/Morshimus/yandex-cloud-instance-module?ref=tags/1.0.0"

  for_each = toset(["001", "002"])

  source_image_family = "ubuntu-2204-lts"

  prefix = "swarm-worker"

  postfix = each.key

  boot_disk = {
    initialize_params = {
      size = var.os_disk_size
      type = "network-ssd"
    }
  }

  network_interface = [
    {
      subnet_id      = yandex_vpc_subnet.morsh-subnet-a.id
      nat            = true
      nat_ip_address = each.key == "001" ? yandex_vpc_address.morsh-addr-pub_2.external_ipv4_address[0].address : yandex_vpc_address.morsh-addr-pub_3.external_ipv4_address[0].address
    }
  ]

  vm_vcpu_qty = 2
  vm_ram_qty  = 2
  adm_pub_key = tls_private_key.key.public_key_openssh
  useros      = var.useros
}



####################### Keys ##########################################################

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "${path.module}/morsh_server_SSH"
}



############### Inventory and Ansible Provisioning ###########################################################

resource "local_file" "yandex_inventory" {
  content  = local.ansible_template
  filename = "${path.module}/yandex_cloud.ini"

  provisioner "local-exec" {
    command     = "Wait-Event -Timeout 60;wsl -e /bin/bash -c 'cp .vault_pass_D13  ~/.vault_pass_D13 ; chmod 0600 ~/.vault_pass_D13';wsl -e /bin/bash -c 'cp morsh_server_SSH  ~/.ssh/morsh_server_SSH ; chmod 0600 ~/.ssh/morsh_server_SSH'; . ./actions.ps1;ansible-playbook -secret"
    interpreter = ["powershell.exe", "-NoProfile", "-c"]
  }

}