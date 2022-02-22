#!/bin/bash

######################################################
#
# File ./scripts/deploy-frontend-assets.sh
# This script deploys the frontend assets in the S3 bucket
#
# How to use (from the project root directory):
# - Make sure the file is executable  :   chmod +x ./scripts/deploy-frontend-assets.sh
# - Deploy all the changes            :   ./scripts/deploy-frontend-assets.sh
#

function main {
    ROOT_DIR=$(pwd)
    source "$ROOT_DIR/scripts/steps/common.sh"

    setDeploymentConfig
    introComments "apply"

    source "$ROOT_DIR/scripts/steps/terraform.sh"

    TF_FOLDER=frontend
    cd "$ROOT_DIR/terraform/$TF_FOLDER"
    getOutputsForFrontend

    source "$ROOT_DIR/scripts/steps/frontend-assets.sh"
    cd "$ROOT_DIR" || exit
    frontendAssetsSteps
}

main
