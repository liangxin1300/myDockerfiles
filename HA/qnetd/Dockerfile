FROM liangxin1300/hatbw
MAINTAINER Xin Liang <XLiang@suse.com>

# docker build -t hatbw --build-arg ssh_prv_key="$(cat /root/.ssh/id_rsa)" --build-arg ssh_pub_key="$(cat /root/.ssh/id_rsa.pub)" .
# docker login
# docker tag hatbw liangxin1300/hatbw
# docker push liangxin1300/hatbw

RUN zypper -n install corosync-qnetd
RUN systemctl enable corosync-qnetd.service
RUN systemctl start corosync-qnetd.service
