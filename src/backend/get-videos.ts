import type { APIGatewayRequestAuthorizerEvent } from 'aws-lambda';
import { dynamodbClientV3, logger, tracer } from './common';
import { Video } from './common/types/Video';
import { QueryCommand } from '@aws-sdk/client-dynamodb';

import middy from '@middy/core';
import { injectLambdaContext } from '@aws-lambda-powertools/logger';
import { captureLambdaHandler } from '@aws-lambda-powertools/tracer';

const dynamoDBTableVideos = process.env.TABLE_NAME_VIDEOS || '';
const dynamoDBIndex = process.env.DISPLAYED_VIDEOS_INDEX_NAME || '';

const getVideos = async (): Promise<Array<Video>> => {

  const command = new QueryCommand({
    TableName: dynamoDBTableVideos,
    IndexName: dynamoDBIndex,
    KeyConditionExpression: '#isDisplayed = :isDisplayed',
    ExpressionAttributeNames: { '#isDisplayed': 'isDisplayed' },
    ExpressionAttributeValues: { ':isDisplayed': { S:'true' } },
    ScanIndexForward: true
  });

  try {
    const results = await dynamodbClientV3.send(command);
    logger.debug(`[GET videos] Query results from DynamoDB table ${dynamoDBTableVideos}`, {
      details: { results }
    });

    return results.Items ? results.Items.map((video): Video => ({
      id: video.id.S || '',
      title: video.title.S || '',
      description: video.description.S || '',
      url: video.url.S || '',
      upvotes: video.upvotes.N || '',
      downvotes: video.downvotes.N || '',
    })) : [];
  } catch (error) {
    logger.error(`[GET videos] Error occurred while querying DynamoDB table ${dynamoDBTableVideos}`, error as Error);

    return [];

  }
};

const lambdaHandler = async (event: APIGatewayRequestAuthorizerEvent): Promise<string> => {

  logger.debug('[GET videos] Lambda invoked', {
    details: { event }
  });

  const videos = await getVideos();

  logger.debug('[GET videos] Videos array', {
    details: { videos }
  });

  return JSON.stringify({ 
    region: process.env.AWS_REGION,
    data: videos 
  });
};

const handler = middy(lambdaHandler)
  .use(captureLambdaHandler(tracer))
  .use(injectLambdaContext(logger));

export {
  handler
};
