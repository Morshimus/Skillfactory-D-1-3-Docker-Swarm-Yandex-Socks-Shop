variable "network_name_yandex" {
  type        = string
  description = "Created netowork in yandex.cloud name"
  default     = "morsh_vpc"
}

variable "service_account_key_yandex" {
  type        = string
  default     = "./key.json"
  description = "Local storing service key. Not in git tracking"
}

variable "zone_yandex_a" {
  type        = string
  default     = "ru-central1-a"
  description = "Zone of 1st instance in yandex cloud"
}

variable "cloud_id_yandex" {
  type        = string
  description = "Cloud id of yandex.cloud provider"
}


variable "folder_id_yandex" {
  type        = string
  description = "Folder id of yandex.cloud provider"
}


variable "subnet_a_name_yandex" {
  type        = string
  default     = "morsh-subnet-a"
  description = "Subnet for 1st instance"

}

variable "subnet_a_v4_cidr_blocks_yandex" {
  type        = list(string)
  default     = ["192.168.21.0/24"]
  description = "IPv4 network for 1st instance subnet"
}


variable "subnet_a_description_yandex" {
  type    = string
  default = "Subnet A for morshimus instances"
}



variable "os_disk_size" {
  type        = string
  default     = "15"
  description = "Size of required vm"

}

variable "useros" {
  type    = string
  default = "morsh-adm"
}

variable "name_pubipv4_addr_1" {
  type    = string
  default = "morsh-public-ip-1"

}

variable "name_pubipv4_addr_2" {
  type    = string
  default = "morsh-public-ip-2"

}

variable "name_pubipv4_addr_3" {
  type    = string
  default = "morsh-public-ip-3"

}