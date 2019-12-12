#!/bin/bash
image='liangxin1300/ha'

setup() {
  num_container=${1:-1}
  if ! [[ $num_container =~ ^[1-9][0-9]*$ ]];then
    echo "Usage: setup number"
    return
  fi

  #for i in $(seq $num_container)
  #do
  #  echo "10.10.10.$((i+1)) hanode$i"
  #done
  docker pull ${image}
  docker network create --subnet 10.10.10.0/24 second_net
  
  for i in $(seq $num_container)
  do
    _hostname="hanode$i"
    _ip="10.10.10.$((i+1))"
    echo "node: $_hostname IP: $_ip"
    
    docker run -d --name=$_hostname --hostname $_hostname --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro ${image}
    docker network connect --ip=$_ip second_net $_hostname
  done

  #docker network connect --ip=10.10.10.2 second_net hanode1
  #docker exec -t hanode1 /bin/sh -c "echo \"10.10.10.3 hanode2\" >> /etc/hosts"
}

setup "$1"
