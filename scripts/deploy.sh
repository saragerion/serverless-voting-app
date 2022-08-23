#!/bin/bash

######################################################
#
# File ./scripts/deploy.sh
# This script deploys the Terraform infrastructure on AWS and the frontend assets in the S3 bucket
#
# How to use (from the project root directory):
# - Make sure the file is executable  :   chmod +x ./scripts/deploy.sh
# - Preview the Terraform changes     :   ./scripts/deploy.sh
# - Deploy all the changes            :   ./scripts/deploy.sh apply
#

function main {
    ROOT_DIR=$(pwd)
    source "$ROOT_DIR/scripts/steps/common.sh"
    source "$ROOT_DIR/scripts/steps/terraform.sh"

    setDeploymentConfig
    introComments "$@"

    npm run build
    npm ci "--production"
    cd dist/backend
    zip -r lambda_functions.zip .  ../../package.json ../../node_modules

    for TF_FOLDER in backend frontend okta
    do
        cd "$ROOT_DIR/terraform/${TF_FOLDER}"
        terraformSteps "$@"
    done

    if [ "$1" = "apply" ]; then
        source "$ROOT_DIR/scripts/steps/frontend-assets.sh"
        cd "$ROOT_DIR"
        frontendAssetsSteps
    else
        echo "Above you can see the planned changes. To apply those changes run './scripts/deploy.sh apply' "
    fi

    npm install "--production=false"
}

main "${*}"
