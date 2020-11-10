#!/bin/bash

######################################################
#
# File ./scripts/deploy-terraform.sh
# This script deploys the Terraform infrastructure on AWS
#
# How to use (from the project root directory):
# - Make sure the file is executable  :   chmod +x ./scripts/deploy-terraform.sh
# - Preview the Terraform changes     :   ./scripts/deploy-terraform.sh
# - Deploy all the changes            :   ./scripts/deploy-terraform.sh apply
#

function main {
    ROOT_DIR=$(pwd)
    source "$ROOT_DIR/scripts/steps/common.sh"

    setDeploymentConfig
    introComments "$@"

    source "$ROOT_DIR/scripts/steps/terraform.sh"

    for TF_FOLDER in backend frontend
    do
        cd "$ROOT_DIR/terraform/${TF_FOLDER}"
        terraformSteps "$@"
    done

    if [ ! "$1" = "apply" ]; then
        echo "Above you can see the planned changes. To apply those changes run './scripts/deploy-terraform.sh apply' "
    fi
}

main "${*}"
