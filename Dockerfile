FROM michaeltigr/zebra-php-base:latest

LABEL maintainer "Michael Molchanov <mmolchanov@adyax.com>"

USER root

# Set the Drush version.
ENV DRUSH_VERSION 8.1.18

# Install Drush 8 with the phar file.
RUN curl -fsSL -o /usr/local/bin/drush "https://github.com/drush-ops/drush/releases/download/$DRUSH_VERSION/drush.phar" && \
  chmod +x /usr/local/bin/drush

# Test your install.
RUN drush core-status

# Install docman.
RUN apk add --update --no-cache ruby ruby-dev \
  && rm -rf /var/cache/apk/* \
  && gem install --no-ri --no-rdoc -v 0.0.99 docman

# Install nodejs and grunt.
RUN echo -e "\n@edge http://nl.alpinelinux.org/alpine/edge/main\n@edgecommunity http://nl.alpinelinux.org/alpine/edge/community" | tee -a /etc/apk/repositories \
  && apk add --update --no-cache libuv@edge nodejs@edge nodejs-npm@edge nodejs-dev@edge yarn@edgecommunity \
  && rm -rf /var/cache/apk/* \
  && npm install -g gulp-cli grunt-cli bower \
  && node --version \
  && npm --version \
  && grunt --version \
  && gulp --version \
  && bower --version \
  && yarn versions

# Install compass.
RUN gem install --no-ri --no-rdoc compass

# Install python base.
RUN apk add --update --no-cache \
  build-base \
  libffi \
  libffi-dev \
  python \
  python-dev \
  py-crcmod \
  py-pip \
  && rm -rf /var/lib/apt/lists/*

# Install ansible.
RUN pip install --upgrade pip \
  && pip install ansible==2.4.6.0 awscli s3cmd python-magic

# Install ansistrano.
RUN ansible-galaxy install ansistrano.deploy ansistrano.rollback

# Install Java, druflow & assemble gradle & groovy.
ENV JAVA_HOME=/usr
RUN apk add --update --no-cache openjdk7-jre-base \
  && rm -rf /var/lib/apt/lists/* \
  && git clone --branch=v0.1.4 --depth=1 --single-branch https://github.com/aroq/druflow.git \
  && cd druflow \
  && ./gradlew assemble

RUN addgroup -g 1001 docker && adduser -u 1001 docker docker
USER docker
