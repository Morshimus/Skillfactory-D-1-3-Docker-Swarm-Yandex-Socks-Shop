[swarm_managers]
${manager_name} ansible_host=${manager_ipaddr} ansible_user=${manager_user}
[swarm_workers]
%{ for ind in worker_index ~}
${worker_name[ind]} ansible_host=${worker_ipaddr[ind]} ansible_user=${worker_user}
%{ endfor ~}