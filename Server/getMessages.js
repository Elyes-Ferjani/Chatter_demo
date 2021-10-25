const aws = require('aws-sdk')
aws.config.region = "us-east-1"

const dynamo = new aws.DynamoDB()

const getAllMessages  = async (room) => {

    const time_now = Date.now().toString()

    const params = {
      TableName: "messages",
      KeyExpression: "id < :i And room = :r",
      ExpressionAttributeValues: {
        ":i": {
          N: time_now
        },
        ":r": {
          S: room
        }
      }
    }

    const result = await dynamo.scan(params).promise().catch(err=>err)
    return result.Items.map(item=>{
      return {
          id: item.id?.N,
          room: item.room.S,
          text: item.text.S,
          user: item.user.S
      }
  }).sort((a,b)=> a["id"] - b["id"] )
}

module.exports = { getAllMessages }