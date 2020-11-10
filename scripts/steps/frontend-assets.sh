#!/bin/bash

function checkCodeChanges() {
    SRC_CHECKSUM_FILE=".src-checksum-$AWS_ACCOUNT_ID-$ENV-$AWS_REGION"
    touch "$SRC_CHECKSUM_FILE"

    FILES_DEPLOYED=$(aws s3 ls "s3://$BUCKET_NAME")
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
    cp "src/website/index.html" "dist/index.html"
    mkdir -p "dist/static/$TIMESTAMP"
    cp -r "src/website/static/_local_/." "dist/static/$TIMESTAMP"
    sed -i "" "s/_local_/$TIMESTAMP/g" "dist/index.html"
}

function copyToS3() {
    aws s3 cp "dist/index.html" "s3://$BUCKET_NAME/index.html" \
        --expires $(date -d "+30 minutes" -u +"%Y-%m-%dT%H:%M:%SZ") \
        --cache-control "max-age=1800,public"
    aws s3 cp "dist/static/" "s3://$BUCKET_NAME/static/" \
        --recursive \
        --expires $(date -d "+1 day" -u +"%Y-%m-%dT%H:%M:%SZ") \
        --cache-control "max-age=86400,public"
}

function updateSourceCodeChecksum() {
    find src -exec sha1sum {} \; 2>&1 | sort -k 2 | sha1sum > "$SRC_CHECKSUM_FILE"
}

function clearCloudFrontCache() {
    if [ -n "${CF_DISTRIBUTION}" ]; then
        aws cloudfront create-invalidation \
            --distribution-id "${CF_DISTRIBUTION}" \
            --paths "/index.html"  > /dev/null
    fi
}

function emptyBucket() {
    echo -e "\nEmptying bucket..."
    aws s3 rm "s3://${BUCKET_NAME}" --recursive
}

function printWebsite() {
    if [ -n "${WEBSITE_DOMAIN}" ]; then
        echo -e "\n====================="
        echo "WEBSITE URL"
        echo -e "https://${WEBSITE_DOMAIN}\n"
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

