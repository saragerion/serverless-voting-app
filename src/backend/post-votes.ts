import type { APIGatewayEvent } from 'aws-lambda';
import { Decision, User } from './common/types';
import { PutItemCommand, UpdateItemCommand } from '@aws-sdk/client-dynamodb';
import { dynamodbClientV3, logger, metrics, tracer } from './common';
// eslint-disable-next-line @typescript-eslint/no-var-requires
const got = require('got').default;

import middy from '@middy/core';
import { injectLambdaContext } from '@aws-lambda-powertools/logger';
import { logMetrics, MetricUnits } from '@aws-lambda-powertools/metrics';
import { captureLambdaHandler } from '@aws-lambda-powertools/tracer';

const dynamoDBTableVotes = process.env.TABLE_NAME_VOTES || '';
const dynamoDBTableVideos = process.env.TABLE_NAME_VIDEOS || '';

// This business logic is simplified for the sake of a demo
// The goal is to show an example of querying an external dependency
const getUserUUID = async (): Promise<string> => {

  try {
    const response: User = await got('https://6214c09489fad53b1f1db75c.mockapi.io/api/users/1', {
      timeout: {
        request: 3000
      }
    }).json();

    return response.UUID;
  } catch (error) {
    throw new Error('Unexpected error while while calling the external user service');
  }
};

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
    logger.error(`[POST votes] Error occurred while writing in DynamoDB table ${dynamoDBTableVotes}`, error as Error);
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

  const userId = await getUserUUID();
  const body = JSON.parse(event.body as string);
  const videoId = body.videoId;
  const decision = body.decision;

  await Promise.all([
    storeUserVote(userId, videoId, decision),
    incrementVideoVote(videoId, decision)
  ]);

  metrics.addMetric(decision, MetricUnits.Count, 1);
  tracer.putAnnotation('decision', decision);

  logger.debug(`[POST votes] User vote stored in DynamoDB tables ${dynamoDBTableVideos} and ${dynamoDBTableVideos}`, {
    details: { userId, videoId, decision }
  });

  return JSON.stringify({ success: true });
};

const handler = middy(lambdaHandler)
  .use(captureLambdaHandler(tracer))
  .use(logMetrics(metrics, { captureColdStartMetric: true }))
  .use(injectLambdaContext(logger));

export {
  handler
};
