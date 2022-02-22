import type { APIGatewayEvent } from 'aws-lambda';
import { createHmac } from 'crypto';
import { dynamodbClientV3, logger } from './common';
import { Decision } from './common/types/Decision';
import { PutItemCommand, UpdateItemCommand } from '@aws-sdk/client-dynamodb';
import middy from '@middy/core';
import { injectLambdaContext } from '@aws-lambda-powertools/logger';

const dynamoDBTableVotes = process.env.TABLE_NAME_VOTES || '';
const dynamoDBTableVideos = process.env.TABLE_NAME_VIDEOS || '';

// This business logic is simplified for the sake of a demo,
// do not use in production
const getUserId = (email: string): string => createHmac('sha256', 'MY_FOO_SECRET')
  .update(email)
  .digest('hex');

const storeUserVote = (userId: string, videoId: string, decision: string): Promise<unknown> => {
  try {
    return dynamodbClientV3.send(new PutItemCommand({
      TableName: dynamoDBTableVotes,
      Item: {
        'userId': { S: userId },
        'videoId': { S: videoId },
        'decision': { S: decision }
      },
    }));
  } catch (error) {
    logger.error(`[POST votes] Error occurred while writing in DynamoDB table ${dynamoDBTableVotes}`, error);
    throw new Error(`Unable to write new user vote item in DynamoDB table ${dynamoDBTableVotes}`);
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
  } catch (error) {
    logger.error(`[POST votes] Error occurred while increment a votes value in DynamoDB table ${dynamoDBTableVideos}`, error);
    throw new Error(`Unable to increment votes in DynamoDB table ${dynamoDBTableVideos}`);
  }
};

const lambdaHandler = async (event: APIGatewayEvent): Promise<string> => {

  logger.debug(`[POST votes] Lambda invoked`, {
    details: { event }
  });

  const userId = getUserId(event.requestContext.authorizer?.jwt.claims.sub);
  const body = JSON.parse(event.body as string);
  const videoId = body.videoId;
  const decision = body.decision;

  const results = await Promise.all([
    storeUserVote(userId, videoId, decision),
    incrementVideoVote(videoId, decision)
  ]);

  logger.debug(`[POST votes] User vote stored in DynamoDB tables ${dynamoDBTableVideos} and ${dynamoDBTableVideos}`, {
    details: { results }
  });

  return JSON.stringify({ success: true });
};

const handler = middy(lambdaHandler).use(injectLambdaContext(logger));

export {
  handler
};
