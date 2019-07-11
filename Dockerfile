FROM nextcloud-15.0.8:latest

LABEL maintainer="nuvoletta8"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    iputils-ping \
    jq \
    libmcrypt4 \
    mcrypt \
    python-swiftclient \
    sudo \
    telnet
    #libapache2-mod-security2 iputils-ping util-linux vim-nox lsof

# add credentials on build
#ARG SSH_PRIVATE_KEY
RUN mkdir -p ${HOME}/.ssh/ && \
  echo "${SSH_PRIVATE_KEY}" > ${HOME}/.ssh/id_rsa && \
  chmod 0600 ${HOME}/.ssh/id_rsa && \
  ssh-keyscan my.git >> ${HOME}/.ssh/known_hosts

ADD scripts/start.sh /start.sh

# Add the patched entrypoint to take care about our
# modifications on the main nextcloud tree
ADD scripts/entrypoint.sh /entrypoint.sh

#DEBUG: Uncomment this only if you're developing locally ...
#ADD scripts/config.php /var/www/html/config/config.php
ADD scripts/ports.conf /etc/apache2/ports.conf

RUN chmod +x /start.sh /entrypoint.sh

# remove credentials
RUN rm ${HOME}/.ssh/id_rsa

ONBUILD RUN apt update

EXPOSE 8080 8443

ENTRYPOINT ["/start.sh"]
