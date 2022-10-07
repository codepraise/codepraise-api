#!/bin/bash
# Load profile.sh for new shells
# This script is intended to be copied into /etc/profile.d/ in the container

project_profile="${HOME}${USERPROFILE}/workspace/.devcontainer/profile.sh"
if [ -r "${project_profile}" ]; then
  source "${project_profile}"
else
  echo "WARNING: ${project_profile} not found or not readable"
fi