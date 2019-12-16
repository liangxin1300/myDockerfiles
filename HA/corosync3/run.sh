#!/bin/bash
image='liangxin1300/corosync3'

setup_nodes() {
  docker pull ${image}
  docker network create --subnet 10.10.10.0/24 second_net
  echo "################## Setup $num_container nodes"
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
      sed_cmd="echo -e \"  node {\n    ring0_addr: $sub_ip\n    nodeid: $i\n    name: $sub_hostname\n  }\" >> /opt/node_list.txt"
      docker exec -t $_hostname /bin/sh -c "$sed_cmd"
      if [ $sub_hostname == $_hostname ];then
        continue
      fi
      docker exec -t $_hostname /bin/sh -c "echo \"$sub_ip $sub_hostname\" >> /etc/hosts"
    done

    docker exec -t $_hostname /bin/sh -c "sed -i '/nodelist/r /opt/node_list.txt' /etc/corosync/corosync.conf"
  done
}

setup() {
  echo "################## Start cluster service on $num_container nodes"
  for i in $(seq $num_container)
  do
    _hostname="hanode$i"
    docker exec -t $_hostname /bin/sh -c "systemctl start corosync.service"
  done
  echo "Done"
}

clean() {
  for i in $(seq $num_container)
  do
    _hostname="hanode$i"
    echo "Kill and rm $_hostname"
    docker container kill $_hostname &> /dev/null
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
  "setup") 
    setup_nodes
    setup
    ;;
  "clean") clean;;
  "tt") tt;;
  "setup_nodes") setup_nodes;;
  *) echo "Usage: setup/clean number";;
esac
