'use strict';

const AWS = require('aws-sdk');
const error = require('./lib/error.js');

const docClient = new AWS.DynamoDB.DocumentClient({ region: process.env.AWS_REGION });
//const docScan = new AWS.DynamoDB({ region: process.env.AWS_REGION });
const sqs = new AWS.SQS();
const sns = new AWS.SNS({region: process.env.AWS_REGION});

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const msgAttrs = event.Records[0].messageAttributes;
  const deleteParams = {
    QueueUrl: process.env.QueueURL,
    ReceiptHandle: event.Records[0].receiptHandle
  };


  function executeUpload(guid,origVideoName,newVideoName) {
    const stepfunctions = new AWS.StepFunctions({
      region: process.env.AWS_REGION
    });

    const input = {
      guid: guid,
      origVideoName: origVideoName,
      newVideoName: newVideoName,
      workflowStatus: 'upload'
    };

    const dbparams = {
      TableName: process.env.DynamoDBTable,
      Key: {
        guid: guid
      },
      UpdateExpression: 'set newVideoName = :na',
      ExpressionAttributeValues: { ':na': newVideoName }
    };

    console.log('Dynamo update -> New Video Name: ', JSON.stringify(dbparams, null, 2));
    docClient.update(dbparams, (err, data) => {
      if (err) {
        console.log('Error while updating newVideoName:', err);
      } else {
        console.log('Successfully updated newVideoName:');
      }
    });

    const params = {
      stateMachineArn: process.env.UploadWorkflow,
      input: JSON.stringify(input),
      name: guid
    };

    console.log('workflow execute: ', JSON.stringify(input, null, 2));

    stepfunctions.startExecution(params).promise()
      .then(() => {
        console.log("Workflow success executed");
        callback(null, 'success');
        console.log("Workflow success executed after callback");
        })
      .catch((err) => {
        event.guid = guid;
        sqs.deleteMessage(deleteParams);
        error.handler(event, err);
        console.log("Upload Workflow failed");
        //callback(err);
      });
  }

  if ((('guid' in msgAttrs) && ('newVideoName' in msgAttrs)) || ('origVideoName' in msgAttrs)) {
    let guid;
    let newVideoName;

    const origVideoName = event.Records[0].messageAttributes.origVideoName.stringValue;

    if (!('guid' in msgAttrs)) {
      const scanparams = {
        TableName: process.env.DynamoDBTable,
        ProjectionExpression: "guid",
        FilterExpression: "origVideoName = :name",
        ExpressionAttributeValues: { ":name": origVideoName }
      };

      console.log('Scanning table for guid using origVideoName...');

      docClient.scan(scanparams).promise()
      .then((dbRes) => {
        console.log('Scan successful using origVideoName', JSON.stringify(dbRes, null, 2));
        if ( dbRes.Count === 1 ) {
          guid = dbRes.Items[0].guid;
          newVideoName = event.Records[0].messageAttributes.newVideoName.stringValue;
          executeUpload(guid,origVideoName,newVideoName);
        } else {
           let errparams = {
              srcVideo: origVideoName,
              workflowStatus: 'error'
           };
           let params = {
              Message: JSON.stringify(errparams, null, 2),
              Subject: 'Workflow Error - Guid not found',
              TargetArn: process.env.NotificationSns
            };
            sns.publish(params).promise()
              .then(() => {
                  console.log('Notification successfully sent');
              })
              .catch(() => {
                  console.log('Error while sending notification');
              });
            }
        }).catch((err) => {
          console.log('Error while scanning table for guid using origVideoName', JSON.stringify(err, null, 2));
          callback(err);
        });
    } else {
      guid = event.Records[0].messageAttributes.guid.stringValue;
      newVideoName = event.Records[0].messageAttributes.newVideoName.stringValue;

      executeUpload(guid,origVideoName,newVideoName);

    }
  } else {
    console.log('Insufficient Arguments');
    sqs.deleteMessage(deleteParams);
    callback(null, 'Error');
  }
};
