FROM centos

RUN yum -y update && yum -y install curl nginx wget git epel-release net-tools nmap

RUN sed -i.bak 's/80/8080/g' /etc/nginx/nginx.conf
RUN sed -i.bak 's/443/8433/g' /etc/nginx/nginx.conf
RUN sed -i.bak 's/user nginx/#user nginx/'  /etc/nginx/nginx.conf
RUN sed -i.bak 's/pid \/run/pid \/tmp/'  /etc/nginx/nginx.conf

RUN wget https://storage.googleapis.com/hey-release/hey_linux_amd64 && \
    mv hey_linux_amd64 /usr/local/bin/hey && \
    chmod 755 /usr/local/bin/hey

EXPOSE 8080/tcp
EXPOSE 8443/tcp

COPY /nginx.sh /
RUN chmod 777 /nginx.sh

USER 1001 

ENTRYPOINT [ "/nginx.sh" ]