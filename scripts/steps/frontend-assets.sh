#!/bin/bash

function checkCodeChanges() {
    SRC_CHECKSUM_FILE=".src-checksum-$AWS_ACCOUNT_ID-$ENV-$AWS_REGION"
    touch "$SRC_CHECKSUM_FILE"

    FILES_DEPLOYED=$(aws s3 ls --region "$AWS_REGION" "s3://${BUCKET_NAME//\"}")
    if [ -z "${FILES_DEPLOYED}" ]; then
        return
    fi

    if [ "$(cat "$SRC_CHECKSUM_FILE")" = "$(find src -exec sha1sum {} \; 2>&1 | sort -k 2 | sha1sum)" ]; then
        echo -e "\n====================="
        echo "FRONTEND CHANGES"
        echo "No change detected in the static assets, deployment not needed."
        printWebsite
        exit
    fi
}

function buildAssets() {
    rm -R "dist"
    mkdir "dist"
    cp "src/frontend/index.html" "dist/index.html"
    mkdir -p "dist/static/$TIMESTAMP"
    cp -r "src/frontend/static/_local_/." "dist/static/$TIMESTAMP"
    sed -i "" "s/_local_/$TIMESTAMP/g" "dist/index.html"
    sed -i "" "s/_okta_base_url_/${OKTA_BASE_URL//\"}/g" "dist/static/$TIMESTAMP/js/script.js"
    sed -i "" "s/_okta_client_id_/${OKTA_CLIENT_ID//\"}/g" "dist/static/$TIMESTAMP/js/script.js"
    sed -i "" "s/_okta_org_name_/${OKTA_ORG_NAME//\"}/g" "dist/static/$TIMESTAMP/js/script.js"
    sed -i "" "s/_cloudfront_distribution_alias_/${CLOUDFRONT_DISTRIBUTION_ALIAS//\"}/g" "dist/static/$TIMESTAMP/js/script.js"
}

function copyToS3() {
    aws s3 cp "dist/index.html" "s3://${BUCKET_NAME//\"}/index.html" \
        --region "$AWS_REGION" \
        --expires $(gdate -d "+30 minutes" -u +"%Y-%m-%dT%H:%M:%SZ") \
        --cache-control "max-age=1800,public"
    aws s3 cp "dist/static/" "s3://${BUCKET_NAME//\"}/static/" \
        --region "$AWS_REGION" \
        --recursive \
        --expires $(gdate -d "+1 day" -u +"%Y-%m-%dT%H:%M:%SZ") \
        --cache-control "max-age=86400,public"
}

function updateSourceCodeChecksum() {
    find src -exec sha1sum {} \; 2>&1 | sort -k 2 | sha1sum > "$SRC_CHECKSUM_FILE"
}

function clearCloudFrontCache() {
    if [[ -n $CF_DISTRIBUTION_ID ]]; then
        aws cloudfront create-invalidation --region "$AWS_REGION" --distribution-id ${CF_DISTRIBUTION_ID//\"} --paths "/index.html"  > /dev/null
    fi
}

function emptyBucket() {
    echo -e "\nEmptying bucket..."
    aws s3 rm --region "$AWS_REGION" "s3://${BUCKET_NAME//\"}" --recursive
}

function printWebsite() {
    if [[ -n $CLOUDFRONT_DISTRIBUTION_ALIAS ]]; then
        echo -e "\n====================="
        echo "WEBSITE URL"
        echo "https://${CLOUDFRONT_DISTRIBUTION_ALIAS//\"}"
    fi
}

function frontendAssetsSteps() {
    checkCodeChanges
    buildAssets
    copyToS3
    updateSourceCodeChecksum
    clearCloudFrontCache
    printWebsite
}

