
'use strict';
const AWS = require('aws-sdk');
const error = require('./lib/error.js');

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const sns = new AWS.SNS({
    region: process.env.AWS_REGION
  });

  let msg = {};
  let subject;

  if (event.workflowStatus === 'upload') {
    msg = {
      "srcVideo": event.origVideoName,
      "workflowStatus": event.workflowStatus,
      "guid": event.guid
    };
    subject = 'Video Uploaded :- ' + event.guid;
  }


  if (event.workflowStatus === 'ingest') {
    var body_hsh = JSON.parse(`${event.srcMediainfo}`);

    msg = {
      "StartTime": event.startTime,
      "srcVideo": event.srcVideo,
      "guid": event.guid,
      "mimeType": body_hsh.container.mimeType,
      "workflowStatus": 'processing'
    };
    subject = 'Workflow started :- ' + event.guid;
  }

  if (event.workflowStatus === 'complete') {
    msg.guid = event.guid;
    msg.srcVideo = event.srcVideo;
    msg.workflowStatus = event.workflowStatus;
    if (event.hlsUrl) msg.hlsUrl = event.hlsUrl;
    if (event.dashUrl)  msg.dashUrl = event.dashUrl;
    if (event.mp4Outputs) msg.mp4Outputs = event.mp4Outputs;
    if (event.frameCapture) msg.posterUrls = event.posterUrls;
    subject = 'Workflow completed :- ' + event.guid;
  }

  console.log('Sending Notification: ',JSON.stringify(msg, null, 2));

  let params = {
    Message: JSON.stringify(msg, null, 2),
    Subject: subject,
    TargetArn: process.env.NotificationSns
  };

  sns.publish(params).promise()
    .then(() => {
      callback(null, event);
    })
    .catch(err => {
      error.handler(event, err);
      callback(err);
    });
};
