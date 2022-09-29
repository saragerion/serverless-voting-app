#!/bin/bash

function createBackendConfigFile() {
    mkdir -p "$ROOT_DIR/scripts/config/$AWS_ACCOUNT_ID"

    BACKEND_CONFIG_FILE="${ROOT_DIR}/scripts/config/${AWS_ACCOUNT_ID}/backend.sh"

    echo -e "\n====================="
    touch $BACKEND_CONFIG_FILE
    echo "#!/bin/bash" > $BACKEND_CONFIG_FILE
    echo >> $BACKEND_CONFIG_FILE
    echo "export TF_VAR_backend_region=$STATE_AWS_REGION" >> $BACKEND_CONFIG_FILE
    echo "export TF_VAR_backend_bucket=$STATE_S3_BUCKET_NAME" >> $BACKEND_CONFIG_FILE
    echo "export TF_VAR_backend_table=$STATE_DYNAMODB_TABLE_NAME"  >> $BACKEND_CONFIG_FILE

    echo "File $BACKEND_CONFIG_FILE created, with the following content:"
    cat $BACKEND_CONFIG_FILE
}

function checkBackendConfigFile() {

    if [ ! "$TF_FOLDER" = "state" ]; then
        BACKEND_CONFIG_FILE="${ROOT_DIR}/scripts/config/${AWS_ACCOUNT_ID}/backend.sh"
        if [ ! -f "$BACKEND_CONFIG_FILE" ]; then
            echo -e "\n====================="
            echo "ERROR! File $BACKEND_CONFIG_FILE not found, please create the file in this repository with the following content:"
            echo "#!/bin/bash"
            echo "export TF_VAR_backend_region=[the AWS region where your dynamodb table and s3 bucket are located]"
            echo "export TF_VAR_backend_bucket=[the name of the s3 bucket]"
            echo "export TF_VAR_backend_table=[the name of the dynamodb table]"
            exit 1
        fi

        source "$BACKEND_CONFIG_FILE"
    fi
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
    echo "TF_VAR_backend_key=$TF_VAR_backend_key"
    echo "TF_VAR_env=$TF_VAR_env"
    echo "TF_VAR_aws_region=$TF_VAR_aws_region"
    echo "TF_VAR_github_repo=$TF_VAR_github_repo"
    echo "TF_VAR_owner=$TF_VAR_owner"
    echo "TF_VAR_hosted_zone=$TF_VAR_hosted_zone"
    echo "TF_VAR_cloudfront_distribution_url=$TF_VAR_cloudfront_distribution_url"
}

function terraformInit() {
    checkBackendConfigFile

    if [ -n "${BACKEND_KEY}" ]; then
        PREVIOUS_BACKEND_KEY=$BACKEND_KEY
    fi

    BACKEND_KEY="$GITHUB_REPO/$ENV/$AWS_REGION/$TF_FOLDER/terraform.tfstate"

    export TF_DATA_DIR="./.terraform/$AWS_ACCOUNT_ID-$ENV-$AWS_REGION-$TF_FOLDER"
    export TF_VAR_backend_key=$PREVIOUS_BACKEND_KEY
    export TF_VAR_env=$ENV
    export TF_VAR_aws_region=$AWS_REGION
    export TF_VAR_github_repo=$GITHUB_REPO
    export TF_VAR_owner=$OWNER
    export TF_VAR_hosted_zone=$AWS_HOSTED_ZONE_NAME
    export TF_VAR_okta_app_domain="$OKTA_ORG_NAME.$OKTA_BASE_URL"

    if [ "$TF_FOLDER" = "state" ]; then
        terraform init -upgrade -reconfigure
    else
        terraform init -upgrade -reconfigure \
            -backend-config="key=$BACKEND_KEY" \
            -backend-config="region=$TF_VAR_backend_region" \
            -backend-config="bucket=$TF_VAR_backend_bucket" \
            -backend-config="dynamodb_table=$TF_VAR_backend_table"
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

function getCrossRegionInfraOutputs() {
    VIDEOS_GLOBAL_TABLE=$(terraform output --raw videos_table_name)
    VOTES_GLOBAL_TABLE=$(terraform output --raw votes_table_name)
    DISPLAYED_VIDEOS_INDEX_NAME=$(terraform output --raw displayed_videos_index_name)
    echo -e "\n====================="
    echo "TERRAFORM OUTPUTS"
    echo "VIDEOS_GLOBAL_TABLE=$VIDEOS_GLOBAL_TABLE"
    echo "VOTES_GLOBAL_TABLE=$VOTES_GLOBAL_TABLE"
    echo "DISPLAYED_VIDEOS_INDEX_NAME=$DISPLAYED_VIDEOS_INDEX_NAME"
}

function getFrontendOutputs() {
    BUCKET_NAME=$(terraform output --raw s3_bucket)
    CF_DISTRIBUTION_ID=$(terraform output --raw cloudfront_distribution_id)
    CLOUDFRONT_DISTRIBUTION_DOMAIN=$(terraform output --raw cloudfront_distribution_domain)
    CLOUDFRONT_DISTRIBUTION_ALIAS=$(terraform output --raw cloudfront_distribution_alias)
    echo -e "\n====================="
    echo "TERRAFORM OUTPUTS"
    echo "BUCKET_NAME=$BUCKET_NAME"
    echo "CF_DISTRIBUTION_ID=$CF_DISTRIBUTION_ID"
    echo "CLOUDFRONT_DISTRIBUTION_DOMAIN=$CLOUDFRONT_DISTRIBUTION_DOMAIN"
    echo -e "CLOUDFRONT_DISTRIBUTION_ALIAS=$CLOUDFRONT_DISTRIBUTION_ALIAS"
}

function getOktaOutputs() {
    OKTA_CLIENT_ID=$(terraform output --raw okta_app_client_id)
    echo -e "\n====================="
    echo "TERRAFORM OUTPUTS"
    echo -e "OKTA_CLIENT_ID=$OKTA_CLIENT_ID"
}

function getBackendOutputs() {
    VIDEOS_TABLE=$(terraform output --raw videos_table_name)
    VIDEOS_TABLE=${VIDEOS_TABLE//\"}
    echo -e "\n====================="
    echo "TERRAFORM OUTPUTS"
    echo "VIDEOS_TABLE=$VIDEOS_TABLE"
}

function getStateOutputs() {
    STATE_S3_BUCKET_NAME=$(terraform output --raw state_s3_bucket)
    STATE_DYNAMODB_TABLE_NAME=$(terraform output --raw state_dynamodb_table)
    STATE_AWS_REGION=$(terraform output --raw state_aws_region)

    echo -e "\n====================="
    echo "TERRAFORM OUTPUTS"
    echo "STATE_S3_BUCKET_NAME=$STATE_S3_BUCKET_NAME"
    echo "STATE_DYNAMODB_TABLE_NAME=$STATE_DYNAMODB_TABLE_NAME"
    echo -e "STATE_AWS_REGION=$STATE_AWS_REGION"
}

function terraformSteps() {
    terraformInit
    printConfig
    printInputVariables
    terraformValidate
    terraformPlan

    # Initialize Terraform's variables based on the stack getting created
    if [ "$TF_FOLDER" = "cross-region-infra" ]; then
        getCrossRegionInfraOutputs

        export TF_VAR_videos_global_table=${VIDEOS_GLOBAL_TABLE}
        export TF_VAR_votes_global_table=${VOTES_GLOBAL_TABLE}
        export TF_VAR_displayed_videos_index_name=${DISPLAYED_VIDEOS_INDEX_NAME}
    fi
    if [ "$TF_FOLDER" = "frontend" ]; then
        getFrontendOutputs

        export TF_VAR_cloudfront_distribution_url=https://${CLOUDFRONT_DISTRIBUTION_DOMAIN//\"}
    fi
    if [ "$TF_FOLDER" = "okta" ]; then
        getOktaOutputs
    fi
    if [ "$TF_FOLDER" = "backend" ]; then
        getBackendOutputs

        export VIDEOS_TABLE=${VIDEOS_TABLE}
    fi

    if [ "$1" = "apply" ]; then
        terraformApply
    fi
}

function getOutputsForFrontend() {
    terraformInit
    printConfig
    getFrontendOutputs
}

function terraformDestroyInit() {
    terraformInit
    terraformValidate
    echo "Outputs before the destroy command:"
    getFrontendOutputs
}

function terraformDestroySteps() {
    terraformDestroy
}
