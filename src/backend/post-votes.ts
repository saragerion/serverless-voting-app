// eslint-disable-next-line import/no-unresolved
import { APIGatewayEvent } from "aws-lambda";
import { createHmac } from "crypto";
import { dynamodbClient } from "./common/dynamodb-client";
import { PromiseResult } from "aws-sdk/lib/request";
import { AWSError } from "aws-sdk/lib/error";
import { PutItemInput, QueryOutput, UpdateItemInput } from "aws-sdk/clients/dynamodb";
import { Decision } from "./common/types/Decision";

const getUserId = (email: string): string => createHmac("sha256", "MY_FOO_SECRET")
  .update(email)
  .digest("hex");

const storeUserVote = (userId: string, videoId: string, decision: string): Promise<PromiseResult<QueryOutput, AWSError>> => {
  const params: PutItemInput = {
    TableName: process.env.TABLE_NAME_VOTES || "",
    Item: {
      "userId": {
        S: userId
      },
      "videoId": {
        S: videoId
      },
      "decision": {
        S: decision
      }
    },

  };

  try {
    return dynamodbClient.putItem(params).promise();
  } catch (err) {
    console.log(err);
    throw new Error("Unable to write new vote item in DynamoDB");

  }
};

const incrementVideoVote = (videoId: string, decision: Decision): Promise<PromiseResult<QueryOutput, AWSError>> => {
  const attribute: string = (decision == "upvote") ? "upvotes" : "downvotes";
  const params: UpdateItemInput = {
    TableName: process.env.TABLE_NAME_VIDEOS || "",
    Key: { "id": { "S": videoId } },
    ExpressionAttributeValues: { ":incr": { "N": "1" } },
    UpdateExpression: "ADD #vote :incr",
    ExpressionAttributeNames: { "#vote": attribute },
    ReturnValues: "ALL_NEW"
  };

  console.log(params);

  try {
    return dynamodbClient.updateItem(params).promise();
  } catch (err) {
    console.log(err);
    throw new Error("Unable to write new vote item in DynamoDB");

  }
};

const handler = async (event: APIGatewayEvent): Promise<string> => {
  console.log(event);
  const { jwt } = event.requestContext.authorizer || { jwt : { claims: { sub: `foo-${Date.now()}@bar.com` } } };
  const userId = getUserId(jwt.claims.sub);

  let body;
  if (event.body == null) {
    body = {
      videoId : `foo-${Date.now()}`,
      decision: "upvote"
    };
  } else {
    body = JSON.parse(event.body);
  }

  const videoId = body.videoId;
  const decision = body.decision;

  const results = await Promise.all([
    storeUserVote(userId, videoId, decision),
    incrementVideoVote(videoId, decision)
  ]);
  console.log(results);

  return JSON.stringify({ success: true });
};

export {
  handler
};
