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
    read -r -p "Enter the domain used for the website (public hosted zone) [$AWS_HOSTED_ZONE_NAME]: " HOSTED_ZONE
    AWS_HOSTED_ZONE_NAME=${HOSTED_ZONE:-$(echo $AWS_HOSTED_ZONE_NAME)}

    read -r -p "Enter the name of the OKTA org name [$OKTA_ORG_NAME]: " ORG_NAME
    OKTA_ORG_NAME=${ORG_NAME:-$(echo $OKTA_ORG_NAME)}
    read -r -p "Enter the name of the OKTA base url [$OKTA_BASE_URL]: " BASE_URL
    OKTA_BASE_URL=${BASE_URL:-$(echo $OKTA_BASE_URL)}
    read -s -p "Enter the name of the OKTA API token: " API_TOKEN
    OKTA_API_TOKEN=${API_TOKEN:-$(echo $OKTA_API_TOKEN)}
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

function populateData() {

    echo "Adding a video to the voting app..."
    ID=$(date +%s%N)
    aws dynamodb put-item --table-name $VIDEOS_TABLE \
        --item \
            '{"id":{"S":"'$ID'"},"description":{"S":"AWSome video #'$ID' description"},"displayedFrom":{"N":"'$(date +%s)'"},"isDisplayed":{"S":"true"},"title":{"S":"AWSome video #'$ID' title"},"url":{"S":"https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8"}, "upvotes": {"N":"0"}, "downvotes": {"N": "0"}}'

    echo "Done!"
}

