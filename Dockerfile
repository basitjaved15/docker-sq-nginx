FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
USER root
RUN apt-get update && apt-get install -y vim nano net-tools zsh curl sudo systemctl default-jre default-jdk zip wget telnet supervisor elinks apt-utils 
RUN apt-get install -y supervisor nginx


RUN mkdir -p /var/log/supervisor

###################SonrQube Conf#####################

#RUN adduser admin sudo
#RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#RUN wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.7.0.41497.zip
RUN wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.2.1.49989.zip
RUN unzip sonarqube-9.2.1.49989.zip -d /opt/
RUN mv /opt/sonarqube-9.2.1.49989 /opt/sonarqube
#RUN mv /opt/sonarqube{-8.7.0.41497,} /opt/sonarqube
RUN useradd -M -d /opt/sonarqube/ -r -s /bin/bash sonarqube
RUN sudo usermod -aG sudo sonarqube
RUN echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
RUN sudo sysctl -p

RUN mkdir -p /scripts
WORKDIR /scripts
RUN sudo usermod -aG sudo sonarqube
RUN chown -R sonarqube:sonarqube /opt/sonarqube/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

################NGINX Conf#################
COPY nginx.conf /scripts/nginx.conf
COPY nginx.conf  /etc/nginx/
COPY certs /scripts/certs
COPY certs /etc/pki/tls/sonar
RUN nginx -t
################################


EXPOSE 80:80
EXPOSE 443:443
CMD ["/usr/bin/supervisord"]
