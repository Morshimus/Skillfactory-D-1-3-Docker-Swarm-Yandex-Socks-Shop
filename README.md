# Skillfactory-D-1-3-Docker-Swarm-Yandex-Socks-Shop

## [Roles](https://github.com/Morshimus/Skillfactory-D-1-3-Docker-Swarm-Yandex-Socks-Shop-Roles)

## Задание:

* [x] - :one: **Подготовить аккаунт в Yandex.Cloud.**

* [x] - :two: **Создать три инстанса в Yandex.Cloud:**
      - ~~Объединить их в сеть.~~
      - ~~Добавить внешний IP для доступа к проекту через браузер.~~

> Сделано в динамической инвентаризации Ansible.

```hcl
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
```

```tpl
[swarm_managers]
${manager_name} ansible_host=${manager_ipaddr} ansible_user=${manager_user}
[swarm_workers]
%{ for ind in worker_index ~}
${worker_name[ind]} ansible_host=${worker_ipaddr[ind]} ansible_user=${worker_user}
%{ endfor ~}
```

* [x] - :three: **Создать Docker Swarm кластер с одной управляющей нодой и двумя worker-нодами.**

> Сделано, создан playbook ansible, для настройки кластера

```yaml
---
- hosts: swarm_managers
  gather_facts: true
  become: yes
  roles:
    - role: infra/docker
  tasks:
    - name: Init Docker Swarm mode
      shell: |
        docker swarm init 
      args:
        executable: /bin/bash
      ignore_errors: true
    - name: Get Mgmt Swarm token
      shell: |
        docker swarm join-token -q worker
      args:
        executable: /bin/bash      
      register:  token_swarm_result
    - name: Set up ansible token_swarm variable
      set_fact: token_swarm={{ token_swarm_result.stdout }} 


- hosts: swarm_workers
  gather_facts: true
  become: yes
  roles:
    - role: infra/docker
  tasks:
    - name: Join workers to Docker Swarm Cluster
      shell: |
       docker swarm join --token {{ hostvars[groups['swarm_managers'][0]]['token_swarm'] }} \  
       {{ hostvars[groups['swarm_managers'][0]]['ansible_eth0']['ipv4']['address'] }}:2377
      args:
       executable: /bin/bash

- hosts: swarm_managers
  become: yes
  tasks:
   - name: Copy static file docker-compose.yml to Docker Swarm Manager leader
     copy:
      src: docker-compose.yml
      dest: ~/docker-compose.yml
   - name: Start service swarm from docker-compose.yml file
     shell: |
       docker stack deploy --compose-file ~/docker-compose.yml sockshop-swarm
     args:
       executable: /bin/bash
```

![image](https://ams03pap004files.storage.live.com/y4mgIwGY4CjpGeI5qCX4BT5uogVDQSjz-aCLt-8JE0i1zDvp4sJf1r1KUqVos-UQSO4jA7oblDwUy30gPb4d9Acu3CGCLPVi2Y2oqciT0340Nk15q0f0vcmQvANmykkrDV8OBxD4em8bHwgUqmcMr6TCTfwLgtT8VoOrlRs7b7-Hxw0O3nj9piizDb76krpZOM_?encodeFailures=1&width=841&height=153)

* [x] - :four: **Задеплоить в swarm-кластер исправленный файл docker-compose.yml.**

> Ok

* [x] - :five: **Проверить в браузере, что проект работает.**

![image](https://ams03pap004files.storage.live.com/y4mqmHCeL6e4cKwGjY9XmSx_FYgxMbVMALAw1xFhC_E4v4oOeG-YJ6wDZZrcUlPRklP2-XadAuIi9TpFeyjXmkRGr4HZko9W8-YgSVriuGGr0_nhPy5-a_QLWJ4LT7ogqi7O3geADVlzok0CURhGuvsSBoe0n2js2c0UjdtKbi60FqFKCGFChXyvXHp5PW4HO1S?encodeFailures=1&width=1563&height=801)

* [x] - :six: **Масштабировать frontend-сервис до двух реплик.**

> Ok можно сделать командой scale, но помоему во благо IaC лучше добавить в compose.

```yaml
    deploy:
     mode: replicated
     replicas: 2
     endpoint_mode: dnsrr
```

* [x] - :seven: **Для проверки задания необходимо отправить:**
      - ~~Описание — каким образом и какие команды использовались для решения задания.~~  
        > Описано выше
      - ~~Скриншот страницы в браузере (главной страницы проекта, работающего в Yandex.Cloud).~~
        > Выложено выше
      - ~~Вывод команды docker service ls.~~
        ![image](https://ams03pap004files.storage.live.com/y4mOr4XU1_CXBMzq75ujggxPPYCTUgSUVKSCKZH_jGHJE5X5wbeke3HtSzgHDd-WgokukvnY_fmj5bcsADvFH87s-swqQmspfRH1isEarMAn_kDivixMV5ehNQPLsegI8-F7-ltqbKIgnYYraj27VmRP2pkZ0w5np6_w1CKyEfs5Fcf7e5wUntmpj9eC-YJUtlV?encodeFailures=1&width=1367&height=278)
      - ~~Вывод команды docker node ls.~~
        ![image](https://ams03pap004files.storage.live.com/y4mBCMXExrrXH5sx0SOnifkyTV4jxBRlY2PMzV42syibTXvFl825r1FfKpG-eH3Z5z0rJlrEorEp9j5VhQZhJVdXYF0fjCA9lV4sI4S59AFfcWf2ufxXzVZ03QIAJCyakjBOORkolStcz7AbXdVMDHlHWxMCzhuu6UxWpRBLkLvHwKK7MKT63FsXjJWJy-5fp7Y?encodeFailures=1&width=1066&height=113)

* [x] - **Погасить проект.**
      > Нет, будем продавать носки теперь.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.5 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | ~> 0.84.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.84.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_swarm_manager"></a> [swarm\_manager](#module\_swarm\_manager) | git::https://github.com/Morshimus/yandex-cloud-instance-module | tags/1.0.0 |
| <a name="module_swarm_workers"></a> [swarm\_workers](#module\_swarm\_workers) | git::https://github.com/Morshimus/yandex-cloud-instance-module | tags/1.0.0 |

## Resources

| Name | Type |
|------|------|
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.yandex_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [yandex_vpc_address.morsh-addr-pub_1](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_address) | resource |
| [yandex_vpc_address.morsh-addr-pub_2](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_address) | resource |
| [yandex_vpc_address.morsh-addr-pub_3](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_address) | resource |
| [yandex_vpc_network.morsh-network](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_subnet.morsh-subnet-a](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_id_yandex"></a> [cloud\_id\_yandex](#input\_cloud\_id\_yandex) | Cloud id of yandex.cloud provider | `string` | n/a | yes |
| <a name="input_folder_id_yandex"></a> [folder\_id\_yandex](#input\_folder\_id\_yandex) | Folder id of yandex.cloud provider | `string` | n/a | yes |
| <a name="input_name_pubipv4_addr_1"></a> [name\_pubipv4\_addr\_1](#input\_name\_pubipv4\_addr\_1) | n/a | `string` | `"morsh-public-ip-1"` | no |
| <a name="input_name_pubipv4_addr_2"></a> [name\_pubipv4\_addr\_2](#input\_name\_pubipv4\_addr\_2) | n/a | `string` | `"morsh-public-ip-2"` | no |
| <a name="input_name_pubipv4_addr_3"></a> [name\_pubipv4\_addr\_3](#input\_name\_pubipv4\_addr\_3) | n/a | `string` | `"morsh-public-ip-3"` | no |
| <a name="input_network_name_yandex"></a> [network\_name\_yandex](#input\_network\_name\_yandex) | Created netowork in yandex.cloud name | `string` | `"morsh_vpc"` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Size of required vm | `string` | `"15"` | no |
| <a name="input_service_account_key_yandex"></a> [service\_account\_key\_yandex](#input\_service\_account\_key\_yandex) | Local storing service key. Not in git tracking | `string` | `"./key.json"` | no |
| <a name="input_subnet_a_description_yandex"></a> [subnet\_a\_description\_yandex](#input\_subnet\_a\_description\_yandex) | n/a | `string` | `"Subnet A for morshimus instances"` | no |
| <a name="input_subnet_a_name_yandex"></a> [subnet\_a\_name\_yandex](#input\_subnet\_a\_name\_yandex) | Subnet for 1st instance | `string` | `"morsh-subnet-a"` | no |
| <a name="input_subnet_a_v4_cidr_blocks_yandex"></a> [subnet\_a\_v4\_cidr\_blocks\_yandex](#input\_subnet\_a\_v4\_cidr\_blocks\_yandex) | IPv4 network for 1st instance subnet | `list(string)` | <pre>[<br>  "192.168.21.0/24"<br>]</pre> | no |
| <a name="input_useros"></a> [useros](#input\_useros) | n/a | `string` | `"morsh-adm"` | no |
| <a name="input_zone_yandex_a"></a> [zone\_yandex\_a](#input\_zone\_yandex\_a) | Zone of 1st instance in yandex cloud | `string` | `"ru-central1-a"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
