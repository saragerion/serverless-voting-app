# serverless-voting-app

This is a demo voting app built with serverless services.

### Technologies

- AWS services: Amazon CloudFront, Amazon API Gateway, AWS Lambda, Amazon DynamoDB, Amazon S3.
- Okta (Identity Provider)
- Terraform
- AWS Lambda Powertools for TypeScript
- Bash
- K6

### Local Requirements:

You'll need to have Terraform & the AWS CLI installed locally, and an OKTA account.

* Terraform CLI (for example via tfenv)
* AWS CLI
* OKTA env credentials available in your terminal:
    * export OKTA_ORG_NAME=dev-1234567
    * export OKTA_BASE_URL=okta.com
    * export OKTA_API_TOKEN=12345678979654645646556


Run:

1) Deploy the Terraform state hosted on an S3 bucket with a DynamoDB table for state lock in your AWS account:
```shell
chmod +x ./scripts/deploy-state.sh
./scripts/deploy-state.sh apply
```

2) Deploy the app (including OKTA):
```shell
chmod +x ./scripts/deploy.sh
./scripts/deploy.sh apply
```

### Architecture

![Architecture diagram](./docs/images/serverless-voting-app.png)
