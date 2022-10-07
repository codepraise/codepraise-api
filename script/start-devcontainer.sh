#!/bin/bash
# Start the devcontainer

export UID=$(id -u)
export GID=$(id -g)
if [ "${SHELL}" = "/bin/bash" ]; then
  source ~/.bashrc
elif [ "${SHELL}" = "/bin/zsh" ]; then
  source ~/.zshrc
fi

docker-compose up -d --build && docker-compose exec api /bin/bash -l