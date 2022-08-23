#!/bin/bash

######################################################
#
# File ./scripts/deploy-state.sh
# This script deploys the s3 bucket and dynamodb table Terraform's state
#
# How to use (from the project root directory):
# - Make sure the file is executable  :   chmod +x ./scripts/deploy-state.sh
# - Preview the Terraform changes     :   ./scripts/deploy-state.sh
# - Deploy all the changes            :   ./scripts/deploy-state.sh apply
#

function main() {
    ROOT_DIR=$(pwd)
    source "$ROOT_DIR/scripts/steps/common.sh"

    setDeploymentConfig
    introComments "$@"

    source "$ROOT_DIR/scripts/steps/terraform.sh"

    for TF_FOLDER in state; do
        cd "$ROOT_DIR/terraform/${TF_FOLDER}"
        terraformSteps "$@"
    done

    if [ ! "$1" = "apply" ]; then
        echo "Above you can see the planned changes. To apply those changes run './scripts/deploy-state.sh apply' "
    else
      getStateOutputs
      createBackendConfigFile
    fi

}

main "${*}"
