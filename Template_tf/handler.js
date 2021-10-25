const aws = require('aws-sdk')
aws.config.region = "us-east-1"
const dynamo = new aws.DynamoDB()
const sqs = new aws.SQS()
const ssm = new aws.SSM()

exports.handler = async (event) => {

        const body = JSON.parse(event.Records[0].body)
        const time_now = Date.now().toString()
        const ssmParams = {
            Name: "SQS_URL"
        }

        const sqsUrl = await ssm.getParameter(ssmParams).promise()
        .catch(err=>err)

        const sqsParams = {
            QueueUrl: sqsUrl.Parameter.Value,
            ReceiptHandle: event.Records[0].receiptHandle
        }

        const dynamoParams = {
            TableName: "messages",
            Item: {
                "id": {
                    N: time_now
                },
                "room": {
                    S: body.room
                },
                "user": {
                    S: body.user
                },
                "text": {
                    S: body.text
                }
            }
        }
        
        const result = await dynamo.putItem(dynamoParams).promise().then(_=>{
            sqs.deleteMessage(sqsParams).promise().catch(err=>err)
        }).catch(err=>err)
        
        return result

}