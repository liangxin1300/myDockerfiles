FROM liangxin1300/hatbw
MAINTAINER Xin Liang <XLiang@suse.com>

# docker build -t ha .
# docker login
# docker tag ha liangxin1300/ha
# docker push liangxin1300/ha

RUN zypper -n install pacemaker corosync crmsh ha-cluster-bootstrap
COPY corosync.conf /etc/corosync/
COPY authkey /etc/corosync/
