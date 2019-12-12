#!/bin/bash
image='liangxin1300/ha'

setup() {
  docker pull ${image}
  docker network create --subnet 10.10.10.0/24 second_net
  
  for i in $(seq $num_container)
  do
    _hostname="hanode$i"
    _ip="10.10.10.$((i+1))"
    echo "Node: $_hostname IP: $_ip"
    
    docker run -d --name=$_hostname --hostname $_hostname --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro ${image}
    docker network connect --ip=$_ip second_net $_hostname
    for i in $(seq $num_container)
    do
      sub_hostname="hanode$i"
      sub_ip="10.10.10.$((i+1))"
      if [ $sub_hostname == $_hostname ];then
        continue
      fi
      docker exec -t $_hostname /bin/sh -c "echo \"$sub_ip $sub_hostname\" >> /etc/hosts"
    done
  done

  hostname_list=""
  for i in $(seq $num_container)
  do
    hostname_list+="hanode$i "
  done
  cmd="ha-cluster-init -y --no-overwrite-sshkey --nodes \"$hostname_list\""
  docker exec -t hanode1 /bin/sh -c "$cmd"
}

clean() {
  for i in $(seq $num_container)
  do
    _hostname="hanode$i"
    echo "Stop and clean $_hostname"
    docker container stop $_hostname &> /dev/null
    docker container rm $_hostname &> /dev/null
  done

  docker network rm second_net &> /dev/null
  echo "Done"
}

num_container=${2:-1}
if ! [[ $num_container =~ ^[1-9][0-9]*$ ]];then
  echo "Usage: setup/clean number"
  return
fi

tt() {
  :
}

case "$1" in
  "setup") setup;;
  "clean") clean;;
  "tt") tt;;
  *) echo "Usage: setup/clean number";;
esac
