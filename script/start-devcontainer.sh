#!/bin/bash
# Start the devcontainer

project_root=$(dirname "${BASH_SOURCE[0]}")/..
if [ -e ${project_root}/.env ]; then
  source ${project_root}/.env
fi

export COMOPSE_FILE=${COMPOSE_FILE:-"${project_root}/.devcontainer/docker-compose.yml"}
export COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-"codepraise"}

#if [ "${SHELL}" = "/bin/bash" ]; then
#  source ~/.bashrc
#elif [ "${SHELL}" = "/bin/zsh" ]; then
#  source ~/.zshrc
#fi

docker-compose up -d --build && docker-compose exec api /bin/bash -l