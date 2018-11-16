
'use strict';
const AWS = require('aws-sdk');
const error = require('./lib/error.js');

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const docClient = new AWS.DynamoDB.DocumentClient({
    region: process.env.AWS_REGION
  });

  //check the defined presets (resolution) are lessthan or equal to the source
  // height (resolution)

  function presetCheck(height,presets) {
    let newPresets = [];
    presets.forEach(function(p) {
      if (p <= height || p === 270) {
        newPresets.push(p);
      } else {
        console.log(p+' removed from presets as the source is only', height,'p');
      }
    });
    return newPresets;
  }

  let params = {
    TableName: process.env.DynamoDBTable,
    Key: {
      guid: event.guid
    }
  };
  docClient.get(params).promise()
    .then(data => {
      console.log('Scanned DB results', JSON.stringify(data, null, 2));
      Object.keys(data.Item).forEach(function(key) {
        event[key] = data.Item[key];
      });
      
      let info = JSON.parse(data.Item.srcMediainfo);
      event.srcHeight = info.video[0].height;
      event.srcWidth = info.video[0].width;
      //remove mediainfo to reduce payload
      delete event.srcMediainfo;
      
      event.workflowStatus = "processing";

      if (data.Item.hls) {
        event.hls = presetCheck(event.srcHeight,data.Item.hls);
      }
      if (data.Item.mp4) {
        //event.mp4 = presetCheck(event.srcHeight,data.Item.mp4);
        event.mp4 = [1080, 720, 360];
      }
      if (data.Item.dash) {
        event.dash = presetCheck(event.srcHeight,data.Item.dash);
      }

      // Define Height Width for frameCapture thumbnails.
      if (event.frameCapture) {
          event.frameHeight = 720;
          event.frameWdith = 1280;
      }
      
      callback(null, event);
    })
    .catch(err => {
      error.handler(event, err);
      callback(err);
    });
};

