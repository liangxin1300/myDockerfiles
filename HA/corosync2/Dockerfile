FROM opensuse/tumbleweed
MAINTAINER Xin Liang <XLiang@suse.com>

# docker build -t corosync2 .
# docker login
# docker tag corosync2 liangxin1300/corosync2
# docker push liangxin1300/corosync2

ENV container docker

RUN zypper -n install systemd; zypper clean ; \
(cd /usr/lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /usr/lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /usr/lib/systemd/system/local-fs.target.wants/*; \
rm -f /usr/lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /usr/lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /usr/lib/systemd/system/basic.target.wants/*;\
rm -f /usr/lib/systemd/system/anaconda.target.wants/*;

RUN zypper -n install corosync corosync-qdevice iputils iproute2 vim openssh
COPY corosync.conf /etc/corosync/
COPY authkey /etc/corosync/

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/lib/systemd/systemd", "--system"]
