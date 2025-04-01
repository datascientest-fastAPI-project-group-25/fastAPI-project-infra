exports.lambda_handler = async (event, context) => {
    console.log('Received S3 event:', JSON.stringify(event, null, 2));
    
    try {
        // Extract bucket and key information from the event
        const bucket = event.Records[0].s3.bucket.name;
        const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
        
        console.log(`State file changed: s3://${bucket}/${key}`);
        
        // Add your notification logic here
        // For example, you could:
        // - Send a message to SNS/SQS
        // - Post to a Slack webhook
        // - Send an email via SES
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Successfully processed state file change',
                bucket: bucket,
                key: key
            })
        };
    } catch (error) {
        console.error('Error processing S3 event:', error);
        throw error;
    }
};