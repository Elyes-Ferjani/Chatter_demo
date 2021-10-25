const aws = require('aws-sdk')
aws.config.region = "us-east-1"

const sqs = new aws.SQS()
const ssm = new aws.SSM()

const putMessage = async (data) => {

    const ssmParams = {
        Name: 'SQS_URL'
    } 

    const sqsUrl = await ssm.getParameter(ssmParams).promise().catch(err=>console.log(err))

    const sqsParams = {
        QueueUrl: sqsUrl.Parameter.Value,
        MessageBody: JSON.stringify(data)
    }

    const result = await sqs.sendMessage(sqsParams).promise().catch(err=>console.log(err))

}
module.exports = { putMessage }