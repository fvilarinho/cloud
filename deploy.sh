#!/usr/bin/env bash

function prepareToExecute() {
  export TERRAFORM_CMD=$(which terraform)

  cd iac || exit 1
}

function checkDependencies() {
  if [ -z "$TERRAFORM_CMD" ]; then
    echo "`terraform` was not found! Please install it first to continue!"

    exit 1
  fi
}
function deploy() {
  prepareToExecute
  checkDependencies

  $TERRAFORM_CMD init -migrate-state -upgrade || exit 1
  $TERRAFORM_CMD plan -out=/tmp/plan || exit 1
  $TERRAFORM_CMD apply -auto-approve /tmp/plan || exit 1

  rm -rf /tmp/plan
}

deploy