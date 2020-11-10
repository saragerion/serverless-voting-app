#!/bin/bash

######################################################
#
# File ./scripts/destroy-stack.sh
# This script destroys the Terraform infrastructure on AWS
#
# How to use (from the project root directory):
# - Make sure the file is executable  :   chmod +x ./scripts/destroy-stack.sh
# - Destroys all the changes          :   ./scripts/destroy-stack.sh apply
#

function main {
    ROOT_DIR=$(pwd)

    source "$ROOT_DIR/scripts/steps/common.sh"
    source "$ROOT_DIR/scripts/steps/terraform.sh"
    cd "$ROOT_DIR/terraform/service"

    setDeploymentConfig
    terraformDestroyInit

    source "$ROOT_DIR/scripts/steps/frontend-assets.sh"
    emptyBucket

    terraformDestroySteps
}

main
