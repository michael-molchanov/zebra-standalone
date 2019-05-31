FROM michaeltigr/zebra-build-php-drush-docman-tools:0.0.105

LABEL maintainer "Michael Molchanov <mmolchanov@adyax.com>"

USER root

ENV VARIANT_LOG_COLOR_WARN=yellow

# Install python base.
RUN apk add --update --no-cache \
  build-base \
  libffi \
  libffi-dev \
  openssl \
  openssl-dev \
  python2 \
  python2-dev \
  py2-crcmod \
  py2-openssl \
  py2-pip \
  python3 \
  python3-dev \
  py3-crcmod \
  py3-openssl \
  && rm -rf /var/lib/apt/lists/*

# Install ansible.
ENV ANSIBLE_ROLES_PATH=/root/.ansible/roles
RUN pip3 install --upgrade pip \
  && pip3 install ansible==2.7.10 awscli s3cmd python-magic

# Install ansistrano.
RUN ansible-galaxy install ansistrano.deploy ansistrano.rollback

# Install Java, druflow & assemble gradle & groovy.
ENV JAVA_HOME=/usr
RUN apk add --update --no-cache openjdk7-jre-base \
  && rm -rf /var/lib/apt/lists/* \
  && git clone --branch=v0.1.4 --depth=1 --single-branch https://github.com/aroq/druflow.git \
  && cd druflow \
  && ./gradlew assemble

RUN apk add --update --no-cache sudo \
  && rm -rf /var/cache/apk/* \
  &&  addgroup -g 1001 docker \
  && adduser -u 1001 -D -G docker docker \
  && adduser docker wheel \
  && echo "%wheel ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# SSH config.
RUN mkdir -p /home/docker/.ssh && chown docker:docker /home/docker/.ssh
ADD config/ssh /home/docker/.ssh/config
RUN chown docker:docker /home/docker/.ssh/config && chmod 600 /home/docker/.ssh/config

# USER docker

