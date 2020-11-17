import { APIGatewayEvent } from "aws-lambda";
import { DocumentClient } from "aws-sdk/clients/dynamodb";

const dynamoDbClient = new DocumentClient({
    apiVersion: '2012-08-10',
    region: process.env.AWS_REGION || 'eu-central-1'
});

const getVideos = async () => {
    const params = {
        TableName: process.env.TABLE_NAME_VIDEOS || '',
        IndexName: process.env.DISPLAYED_VIDEOS_INDEX_NAME || '',
        KeyConditionExpression: "#isDisplayed = :isDisplayed",
        ExpressionAttributeNames: {
            "#isDisplayed": "isDisplayed"
        },
        ExpressionAttributeValues: {
            ":isDisplayed": "true"
        },
        ScanIndexForward: true
    };

    try {
        const results = await dynamoDbClient.query(params).promise();
        console.log("RESULTS", results);
        return results.Items ? results.Items.map((video) => {
            return {
                id: video.id,
                title: video.title,
                description: video.description,
                url: video.url,
                upvotes: video.upvotes,
                downvotes: video.downvotes,
            }
        }) : [];
    } catch (err) {
        console.error("ERROR", err);
        return [];

    }
}

const handler = async (event: APIGatewayEvent) => {
    console.log(event)
    const videos = await getVideos();
    console.log("VIDEOS", videos);
    console.log('JSON',JSON.stringify({ data: videos }));
    return JSON.stringify({ data: videos });
}

export {
    handler
}
