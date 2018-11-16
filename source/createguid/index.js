'use strict';
const AWS = require('aws-sdk');
const uuid = require('uuid');
const sqs = new AWS.SQS();

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  let key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));
  let guid = uuid.v4();
  let size = event.Records[0].s3.object.size;
  let uploadTime = event.Records[0].eventTime;

  console.log('Vide File Name: ', key);
  console.log('GUID: ', guid);
  console.log('Size: ', size);
  console.log('Upload Time: ', uploadTime);


  const docClient = new AWS.DynamoDB.DocumentClient({
         region: process.env.AWS_REGION
  });

  let params = {
     TableName: process.env.DynamoDBTable,
     Key: {
         guid: guid,
     },
     // remove the trailing ',' from the update expression added by the forEach loop
    UpdateExpression: "set origVideoName = :n, workflowStatus = :s, size = :sz, uploadTime = :ut",
    ExpressionAttributeValues:{
        ":n":key,
        ":s":"received",
        ":sz": size,
        ":ut": uploadTime
    }
  };

 console.log('Dynamo update: ', JSON.stringify(params, null, 2));

 docClient.update(params).promise()
   .then(() => {
       event.guid = guid;
       callback(null, event);
   })
   .catch(err => {
       console.log('Failed to update database');
       console.log(err);
       callback(err);
   });

    let temp_params = {
        guid: guid,
        workflowStatus: 'received',
        srcVideo: key,
        size: size,
        uploadTime: uploadTime
        }

    let message_body = {
        Message : JSON.stringify(temp_params, null, 2)
    };

    let sqsparams = {
        MessageBody: JSON.stringify(message_body, null, 2),
        QueueUrl: process.env.QueueURL,
        DelaySeconds: 0,
    };

    sqs.sendMessage(sqsparams, function(err, data) {
      if (err) console.log(err, err.stack); // an error occurred
      else     console.log(data);           // successful response
    });
};
