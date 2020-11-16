import {DynamoDBClient, QueryCommand} from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: process.env.AWS_REGION });

const getVideos = async () => {
    const command = new QueryCommand({
        TableName: process.env.TABLE_NAME_VIDEOS,
        IndexName: process.env.DISPLAYED_VIDEOS_INDEX_NAME,
        ScanIndexForward: false
    });
    try {
        const results = await client.send(command);
        console.log(results.Items);
        return results.Items?.map((video) => {
            return {
                id: video.id,
                title: video.title,
                description: video.description,
                url: video.url,
                upvotes: video.downvotes,
            }
        })
    } catch (err) {
        console.error(err);
        return [];

    }
}

const handler = async () => {
    const videos = getVideos();
    return { data: JSON.stringify(videos) };
}

export {
    handler
}
