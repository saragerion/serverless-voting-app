// eslint-disable-next-line import/no-unresolved
import { APIGatewayRequestAuthorizerEvent } from "aws-lambda";
import { dynamodbClient } from "./common/dynamodb-client";
import { Video } from "./common/types/Video";
import { AttributeMap, QueryInput } from "aws-sdk/clients/dynamodb";

const getVideos = async (): Promise<Array<Video>> => {
  const params: QueryInput = {
    TableName: process.env.TABLE_NAME_VIDEOS || "",
    IndexName: process.env.DISPLAYED_VIDEOS_INDEX_NAME || "",
    KeyConditionExpression: "#isDisplayed = :isDisplayed",
    ExpressionAttributeNames: {
      "#isDisplayed": "isDisplayed"
    },
    ExpressionAttributeValues: {
      ":isDisplayed": { S:"true" }
    },
    ScanIndexForward: true
  };

  try {
    const results = await dynamodbClient.query(params).promise();
    console.log("RESULTS", results);

    return results.Items ? results.Items.map((video: AttributeMap): Video => ({
      id: video.id.S || "",
      title: video.title.S || "",
      description: video.description.S || "",
      url: video.url.S || "",
      upvotes: video.upvotes.N || "",
      downvotes: video.downvotes.N || "",
    })) : [];
  } catch (err) {
    console.error("ERROR", err);

    return [];

  }
};

const handler = async (event: APIGatewayRequestAuthorizerEvent): Promise<string> => {
  console.log(event);
  console.log(JSON.stringify(event.requestContext, null, 3));
  const videos = await getVideos();
  console.log("VIDEOS", videos);
  console.log("JSON",JSON.stringify({ data: videos }));

  return JSON.stringify({ data: videos });
};

export {
  handler
};
