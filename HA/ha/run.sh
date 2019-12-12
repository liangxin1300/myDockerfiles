#!/bin/bash
Tumbleweed_image='liangxin1300/ha'

setup() {
  num_container=${1:-1}
  if ! [[ $num_container =~ ^[1-9][0-9]*$ ]];then
    echo "bad"
    return
  fi
  echo $num_container
  #docker pull ${Tumbleweed_image}
  #docker network create --subnet 10.10.10.0/24 second_net

  #docker run -d --name=hanode1 --hostname hanode1 --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ${Tumbleweed_image}
  #docker network connect --ip=10.10.10.2 second_net hanode1
  #docker exec -t hanode1 /bin/sh -c "echo \"10.10.10.3 hanode2\" >> /etc/hosts"
}

setup "$1"
