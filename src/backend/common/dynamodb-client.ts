import Dynamodb from "aws-sdk/clients/dynamodb";

const dynamodbClient = new Dynamodb({
  apiVersion: "2012-08-10",
  region: process.env.AWS_REGION || "eu-central-1"
});

export {
  dynamodbClient
};
