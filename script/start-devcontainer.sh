#!/bin/bash
# Start the devcontainer

if [ "${SHELL}" = "/bin/bash" ]; then
  source ~/.bashrc
elif [ "${SHELL}" = "/bin/zsh" ]; then
  source ~/.zshrc
fi

docker-compose up -d --build && docker-compose exec api /bin/bash -l