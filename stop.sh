#!/usr/bin/env bash

function prepareToExecute() {
  export DOCKER_CMD=$(which docker)

  if [ -f ./.secrets ]; then
    source ./.secrets
  fi
}

function checkDependencies() {
  if [ -z "$DOCKER_CMD" ]; then
    echo "`docker` was not found! Please install it first to continue!"

    exit 1
  fi
}

function stop() {
  prepareToExecute
  checkDependencies

  $DOCKER_CMD compose down
}

stop