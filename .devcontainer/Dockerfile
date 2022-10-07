FROM ruby:3.1.1

RUN \
apt update \
&& apt upgrade -y \
&& apt-get install -y sudo \
&& apt-get install -y vim \
&& rm -rf /var/lib/apt/lists/*

COPY load_profile.sh /etc/profile.d/load_profile.sh
RUN chmod +x /etc/profile.d/load_profile.sh

ARG USERNAME
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG PASSWD

RUN groupadd --gid ${USER_GID} ${USERNAME} \
&& useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} --password $(echo ${PASSWD} | openssl passwd -1 -stdin) \
&& usermod -aG sudo ${USERNAME}
