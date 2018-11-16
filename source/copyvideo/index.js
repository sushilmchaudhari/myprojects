'use strict';

const AWS = require('aws-sdk');
const error = require('./lib/error.js');
const s3 = new AWS.S3();

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  s3.copyObject({ 
    CopySource: process.env.srcBucket + '/' + event.origVideoName,
    Bucket: process.env.destBucket,
    Key: event.newVideoName
  }, function(copyErr, copyData){
    if (copyErr) {
      console.log("Error: " + copyErr);
      error.handler(event, copyErr);
      callback(copyErr);
    } else {
      console.log('Copied OK');
      delete event.newVideoName;
      callback(null, event);
    } 
  });  
};
