'use strict';
const AWS = require('aws-sdk');
const error = require('./lib/error.js');
const uuid = require('uuid');
const moment = require('moment');

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const stepfunctions = new AWS.StepFunctions({
    region: process.env.AWS_REGION
  });

  const docClient = new AWS.DynamoDB.DocumentClient({
    region: process.env.AWS_REGION
  });


  let key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));
  let guid;
  let time = moment().utc().format('YYYY-MM-DD HH:mm.S');

  console.log('New Video Name:- ', key);

  var params = {
    TableName: process.env.DynamoDBTable,
    ProjectionExpression: "guid",
    FilterExpression: "newVideoName = :name",
    ExpressionAttributeValues: {
         ":name": key
    }
  };

  console.log("Scanning table...");

  docClient.scan(params).promise()
  .then((data) => {
    console.log("GetItem succeeded:", JSON.stringify(data, null, 2));
    guid = data.Items[0].guid;

    let input = {
    guid: guid,
    srcBucket: event.Records[0].s3.bucket.name,
    abrBucket: process.env.AbrDestination,
    mp4Bucket: process.env.Mp4Destination,
    workflowStatus: "ingest",
    startTime: time
  };

  // get file extension for the source file.
  let keyType = key.slice((key.lastIndexOf(".") - 1 >>> 0) + 2);

  if (keyType === 'json' || keyType === 'xml') {
    input.srcMetadataFile = key;
  } else {
    // video only workflow, encode options are set @ launch as cfn parameters.
    input.srcVideo = key;
    input.mp4 = JSON.parse("[" + process.env.Mp4 + "]");
    input.hls = JSON.parse("[" + process.env.Hls + "]");
    input.dash = JSON.parse("[" + process.env.Dash + "]");
    //convert env.FrameCapture from string to boolean
    if (process.env.FrameCapture === 'true') {
      input.frameCapture = true;
    } else {
      input.frameCapture = false;
    }
    input.imageOverlay = process.env.ImageOverlay;
  }

  let params = {
    stateMachineArn: process.env.IngestWorkflow,
    input: JSON.stringify(input),
    name: guid
  };

  console.log('workflow execute: ', JSON.stringify(input, null, 2));

  stepfunctions.startExecution(params).promise()
    .then(() => callback(null, 'success'))
    .catch(err => {
      error.handler(event, err);
      callback(err);
    });

  })
  .catch(err => {
      console.error("Unable to read item. Error JSON:", JSON.stringify(err, null, 2));
      error.handler(event, err);
      callback(err);
  });

};
