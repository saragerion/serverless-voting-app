#!/bin/bash

function checkBackendConfigFile() {
    BACKEND_CONFIG_FILE="${ROOT_DIR}/scripts/config/${AWS_ACCOUNT_ID}/backend.sh"
    if [ ! -f "$BACKEND_CONFIG_FILE" ]; then
        echo -e "\n====================="
        echo "ERROR! File $BACKEND_CONFIG_FILE not found, please create a backend file with the following content:"
        echo "#!/bin/bash"
        echo "export TF_VAR_backend_region=[the AWS region where your dynamodb table and s3 bucket are located]"
        echo "export TF_VAR_backend_bucket=[the name of the s3 bucket]"
        echo "export TF_VAR_backend_table=[the name of the dynamodb table]"
        exit 1
    fi

    source "$BACKEND_CONFIG_FILE"
}

function printConfig() {
    echo -e "\n**************************************"
    echo "CURRENT FOLDER: ${TF_FOLDER}"
    echo "**************************************"
    echo -e "\n====================="
    echo "TERRAFORM BACKEND CONFIG"
    echo "key=$BACKEND_KEY"
    cat "$BACKEND_CONFIG_FILE"
    echo -e "\n====================="
    echo "TERRAFORM WORKSPACE"
    terraform workspace show
    echo -e "\n====================="
    echo "TERRAFORM ENVIRONMENT VARIABLES"
    echo "TF_DATA_DIR=$TF_DATA_DIR"
}

function printInputVariables() {
    echo -e "\n====================="
    echo "TERRAFORM INPUT VARIABLES"
    echo "TF_VAR_backend_key=$PREVIOUS_BACKEND_KEY"
    echo "TF_VAR_env=$ENV"
    echo "TF_VAR_aws_region=$AWS_REGION"
    echo "TF_VAR_github_repo=$GITHUB_REPO"
    echo -e "TF_VAR_owner=$OWNER\n"
}

function terraformInit() {
    checkBackendConfigFile

    if [ -n "${BACKEND_KEY}" ]; then
        PREVIOUS_BACKEND_KEY=$BACKEND_KEY
    fi

    BACKEND_KEY="$GITHUB_REPO/$ENV/$AWS_REGION/$TF_FOLDER/terraform.tfstate"

    export TF_DATA_DIR="./.terraform/$AWS_ACCOUNT_ID-$ENV-$AWS_REGION-$TF_FOLDER"
    export TF_VAR_env=$ENV
    export TF_VAR_aws_region=$AWS_REGION
    export TF_VAR_backend_key=$PREVIOUS_BACKEND_KEY
    export TF_VAR_github_repo=$GITHUB_REPO
    export TF_VAR_owner=$OWNER

    if [ -z "$TF_VAR_backend_bucket" ]
    then
        terraform init -upgrade -reconfigure \
            -backend-config="key=$BACKEND_KEY" \
            -backend-config="region=$TF_VAR_backend_region" \
            -backend-config="bucket=$TF_VAR_backend_bucket" \
            -backend-config="dynamodb_table=$TF_VAR_backend_table"
    else
        terraform init -upgrade -reconfigure
    fi
}

function terraformValidate() {
    terraform validate
}

function terraformPlan() {
    terraform plan
}

function terraformApply() {
    terraform apply -auto-approve
}

function terraformDestroy() {
    terraform destroy -auto-approve
}

function getOutputs() {
    BUCKET_NAME=$(terraform output s3_bucket)
    CF_DISTRIBUTION=$(terraform output cloudfront_distribution)
    WEBSITE_DOMAIN=$(terraform output website_domain)
    echo -e "\n====================="
    echo "TERRAFORM OUTPUTS"
    echo "BUCKET_NAME=$BUCKET_NAME"
    echo "CF_DISTRIBUTION=$CF_DISTRIBUTION"
    echo -e "WEBSITE_DOMAIN=$WEBSITE_DOMAIN\n"
}

function terraformSteps() {
    terraformInit
    printConfig
    printInputVariables
    terraformValidate
    terraformPlan

    if [ "$1" = "apply" ]; then
        terraformApply
        getOutputs
    fi
}

function getOutputsForFrontend() {
    terraformInit
    printConfig
    getOutputs
}

function terraformDestroyInit() {
    terraformInit
    terraformValidate
    echo "Outputs before the destroy command:"
    getOutputs
}

function terraformDestroySteps() {
    terraformDestroy
}
