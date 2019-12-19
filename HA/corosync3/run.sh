#!/bin/bash
conf="run.conf"
image=`cat $conf|awk -F':[[:space:]]*' '/image/{print $2}'`
network_parent=`cat $conf|awk -F':[[:space:]]*' '/network_parent/{print $2}'`
IFS=";"
set -f
array_parent=($network_parent)
total_number=`cat $conf|awk -F':[[:space:]]*' '/total_number/{print $2}'`
begin_index=`cat $conf|awk -F':[[:space:]]*' '/begin_index/{print $2}'`
end_index=`cat $conf|awk -F':[[:space:]]*' '/end_index/{print $2}'`
num_container=$((end_index-begin_index+1))

setup_nodes() {
  docker pull ${image}
  
  for i in "${!array_parent[@]}"; do
    net_name="net$i"
    parent=`echo ${array_parent[$i]}|awk '{print $1}'`
    sub_net=`echo ${array_parent[$i]}|awk '{print $2}'`
    docker network create -d macvlan --subnet=$sub_net -o parent=$parent $net_name
    echo "docker network create -d macvlan --subnet=$sub_net -o parent=$parent $net_name"
  done

  echo "################## Setup $num_container/$total_number nodes"
  for (( index=$begin_index; index<=$end_index; index++ ))
  do
    _hostname="hanode$index"
    echo "Node: $_hostname"
    
    docker run -d --name=$_hostname --hostname $_hostname --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro ${image}
    for i in "${!array_parent[@]}"; do
      _net_name="net$i"
      _ip_prefix=`echo ${array_parent[$i]}|awk '{print $2}'|awk -F"." '{b=$1FS$2FS$3FS;print b}'`
      _ip="$_ip_prefix$((index+1))"
      docker network connect --ip=$_ip $_net_name $_hostname
    done

    sed_cmd=""
    hosts_str=""
    for (( i=1; i<=$total_number; i++ ))
    do
      sub_hostname="hanode$i"
      _ip_prefix=`echo ${array_parent[0]}|awk '{print $2}'|awk -F"." '{b=$1FS$2FS$3FS;print b}'`
      sub_ip="$_ip_prefix$((i+1))"
      sed_cmd+="  node {\\\n    ring0_addr: $sub_ip\\\n    nodeid: $i\\\n    name: $sub_hostname\\\n  }\\\n"
      if [ $sub_hostname == $_hostname ];then
        continue
      fi
      hosts_str+="$sub_ip $sub_hostname\n"
    done
    docker exec -t $_hostname /bin/sh -c "echo -e \"$sed_cmd\" >> /opt/node_list.txt"
    docker exec -t $_hostname /bin/sh -c "echo -e \"$hosts_str\" >> /etc/hosts"
    docker exec -t $_hostname /bin/sh -c "sed -i '/nodelist/r /opt/node_list.txt' /etc/corosync/corosync.conf"
    docker exec -t $_hostname /bin/sh -c "systemctl start corosync.service"
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
  for (( index=$begin_index; index<=$end_index; index++ ))
  do
    _hostname="hanode$index"
    echo "Kill and rm $_hostname"
    docker container kill $_hostname &> /dev/null
    docker container rm $_hostname &> /dev/null
  done

  for i in "${!array_parent[@]}"; do
    net_name="net$i"
    docker network rm $net_name &> /dev/null
  done
  echo "Done"
}

tt() {
  :
}

case "$1" in
  "setup") 
    setup_nodes
    #setup
    ;;
  "clean") clean;;
  "tt") tt;;
  "setup_nodes") setup_nodes;;
  *) echo "Usage: setup/clean number";;
esac
