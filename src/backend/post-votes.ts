import type { APIGatewayEvent } from 'aws-lambda';
import { createHmac } from 'crypto';
import { dynamodbClientV3 } from './common/dynamodb-client';
import { Decision } from './common/types/Decision';
import { PutItemCommand, UpdateItemCommand } from '@aws-sdk/client-dynamodb';

// This business logic is simplified for the sake of the demo,
// do not use in production
const getUserId = (email: string): string => createHmac('sha256', 'MY_FOO_SECRET')
  .update(email)
  .digest('hex');

const storeUserVote = (userId: string, videoId: string, decision: string): Promise<unknown> => {
  try {
    return dynamodbClientV3.send(new PutItemCommand({
      TableName: process.env.TABLE_NAME_VOTES || '',
      Item: {
        'userId': { S: userId },
        'videoId': { S: videoId },
        'decision': { S: decision }
      },
    }));
  } catch (err) {
    console.log(err);
    throw new Error('Unable to write new vote item in DynamoDB');
  }
};

const incrementVideoVote = (videoId: string, decision: Decision): Promise<unknown> => {
  const attribute: string = (decision == 'upvote') ? 'upvotes' : 'downvotes';

  try {
    return dynamodbClientV3.send(new UpdateItemCommand({
      TableName: process.env.TABLE_NAME_VIDEOS || '',
      Key: { 'id': { 'S': videoId } },
      ExpressionAttributeValues: { ':incr': { 'N': '1' } },
      UpdateExpression: 'ADD #vote :incr',
      ExpressionAttributeNames: { '#vote': attribute },
      ReturnValues: 'ALL_NEW'
    }));
  } catch (err) {
    console.log(err);
    throw new Error('Unable to write new vote item in DynamoDB');

  }
};

const handler = async (event: APIGatewayEvent): Promise<string> => {
  console.log(event);
  const userId = getUserId(event.requestContext.authorizer?.jwt.claims.sub);

  const body = JSON.parse(event.body as string);

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
