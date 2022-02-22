import { DynamoDBClient } from '@aws-sdk/client-dynamodb';

const dynamodbClientV3 = new DynamoDBClient({
  apiVersion: '2012-08-10',
  region: process.env.AWS_REGION || 'eu-central-1'
});

export {
  dynamodbClientV3
};
