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

    for TF_FOLDER in okta frontend backend
    do
        cd "$ROOT_DIR/terraform/${TF_FOLDER}"

        setDeploymentConfig
        terraformDestroyInit
    done

    source "$ROOT_DIR/scripts/steps/frontend-assets.sh"
    emptyBucket

    terraformDestroySteps
}

main
