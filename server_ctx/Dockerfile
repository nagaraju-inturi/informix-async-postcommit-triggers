#FROM centos:7.4.1708
FROM centos
MAINTAINER nagaraju.inturi@hcl.com
ENV INFORMIXDIR /opt/ibm/informix/
ENV LD_LIBRARY_PATH /lib64
RUN mkdir /opt/ibm/  &&  mkdir /opt/ibm/informix
#VOLUME ["/opt/ibm/informix/", "/opt/ibm/data/"]
VOLUME ["/opt/ibm/data/"]
RUN yum -y update && yum -y install libaio sysstat libgcc libstdc compat-libstdc++-33 gcc kernel-headers kernel-devel net-tools.x86_64 xmvn.noarch epel-release mosquitto
RUN yum -y install epel-release mosquitto
#RUN yum -y install libaio sysstat libgcc libstdc compat-libstdc++-33 gcc kernel-headers kernel-devel net-tools.x86_64 xmvn.noarch
RUN /usr/sbin/groupadd -g 102 -f informix
RUN ["/usr/sbin/useradd", "-m", "-g 102", "-u 200", "informix"]
RUN /bin/bash -c 'echo "informix:changeme" | /usr/sbin/chpasswd'
ADD ibm.ids.14.10.FC1.LNX.tar /opt/ibm/informix/
ADD clientsdk.4.50.tar /opt/ibm/informix/
ADD csdk_response.txt /tmp/csdk_response.txt
ADD bundle.properties /tmp/bundle.properties
RUN /opt/ibm/informix/ids_install -i silent -f /tmp/bundle.properties; exit 0
RUN /opt/ibm/informix/installclientsdk  -i SILENT -f /tmp/csdk_response.txt
RUN /bin/bash -c 'chown informix:informix /opt/ibm/data/'
RUN /bin/bash -c '/bin/rm -rf /opt/ibm/informix/ids_install /opt/ibm/informix/IBM_Data_Server_Driver_Package /opt/ibm/informix/CSDK /opt/ibm/informix/ICONNECT /opt/ibm/informix/JDBC /opt/ibm/informix/SDK /opt/ibm/informix/SERVER'

USER informix
RUN /bin/bash -c 'cp /opt/ibm/informix//etc/onconfig.std /opt/ibm/informix//etc/onconfig'
#RUN /bin/bash -c 'cp /opt/ibm/informix//etc/sqlhosts.std /opt/ibm/informix//etc/sqlhosts'
ADD retaildb.sql /opt/ibm/
ADD gamedb.sql /opt/ibm/
ADD mqtt.sql /opt/ibm/
ADD data.unl /opt/ibm/
ADD LeaderBoard.java /opt/ibm/
ADD LeaderBoard.class /opt/ibm/
ADD cmds /opt/ibm/
ADD parallel_iud.ec /opt/ibm/
ADD judrs_mqtt.tar /opt/ibm/

USER root

WORKDIR /opt/ibm
ENTRYPOINT ["/opt/ibm/boot.sh"]
CMD ["--start"]
EXPOSE 60000
ADD boot.sh /opt/ibm/
