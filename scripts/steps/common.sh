#!/bin/bash

function introComments() {
    echo "Getting started..."
    if [ "$1" = "apply" ]; then
        echo "Changes will be applied"
    else
        echo "Changes will not be applied, only visualized"
    fi
}

function getUserInput() {
    read -r -p "Enter the name of the current environment [test]: " ENV
    ENV=${ENV:-test}
    read -r -p "Enter the name of the AWS region where you want to deploy [eu-central-1]: " AWS_REGION
    AWS_REGION=${AWS_REGION:-"eu-central-1"}
    read -r -p "Enter the name of the current repository, *including* the owner [saragerion/serverless-voting-app]: " GITHUB_REPO
    GITHUB_REPO=${GITHUB_REPO:-saragerion/serverless-voting-app}
    read -r -p "Enter the name of the owner of this website, like your name or the name of your team [$(git config user.name)]: " OWNER
    OWNER=${OWNER:-$(git config user.name)}
}

function setDeploymentConfig() {
    TIMESTAMP=$(date +%s)

    getUserInput

    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        echo "Unable to retrieve AWS account. Are you sure your AWS cli credentials are correctly set?"
        exit 1
    fi
}
