
'use strict';
const AWS = require('aws-sdk');
const error = require('./lib/error.js');
const moment = require('moment');

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const s3 = new AWS.S3();

  function validate(bucket, key) {
    let response = new Promise((res, reject) => {
      let params = {
        Bucket: bucket,
        Key: key
      };
      console.log(params);
      s3.headObject(params, function(err, data) {
        if (err) reject(err);
        else {
          res(data);
        }
      });
    });
    return response;
  }

  function getposters(bucket, prefix) {
    let response = new Promise((res, reject) => {
      let params = {
        Bucket: bucket,
        Prefix: prefix
      };
      console.log(params);
      s3.listObjects(params, function(err, data) {
        if (err) reject(err);
        else {
          console.log('List of available posters from S3', JSON.stringify(data, null, 2));
          const arr = data.Contents.map(cur => cur.Key);
          for (let i = 0; i < arr.length; i += 1){
            event.posterUrls[i] = 'https://s3-' + process.env.RegionName + '.amazonaws.com/' + event.mp4Bucket + '/' + arr[i];
          }
          console.log('Poster Urls:', JSON.stringify(event.posterUrls, null, 2));
          res(data);
        }
      });
    });
    return response;
  }


  // create output and validate lists output file
  // output filenames are 'source filename'+'preset'
  let promises = [];
  let mp4Base = event.guid + '/mp4/' + event.srcVideo.split(".").slice(0, -1).join(".");
  let hlsBase = event.guid + '/hls/' + event.srcVideo.split(".").slice(0, -1).join(".");
  let dashBase = event.guid + '/dash/' + event.srcVideo.split(".").slice(0, -1).join(".");
  let key;

  if (event.hls && event.hls.length > 0) {
    event.hlsPlaylist = hlsBase + '.m3u8';
    event.hlsUrl = 'https://'+  process.env.CloudFront + '/' + hlsBase + '.m3u8';
    console.log(event.hlsPlaylist);
    promises.push(validate(event.abrBucket, event.hlsPlaylist));
  }

  if (event.dash && event.dash.length > 0) {
    event.dashPlaylist = dashBase + '.mpd';
    event.dashUrl = 'https://'+ process.env.CloudFront + '/' + dashBase + '.mpd';
    console.log(event.dashPlaylist);
    promises.push(validate(event.abrBucket, event.dashPlaylist));
  }

  if (event.mp4 && event.mp4.length > 0) {
    event.mp4Outputs = {};
    for (let i = event.mp4.length - 1; i >= 0; i--) {
      key = mp4Base + '_' + event.mp4[i] + 'p.mp4';
      let mp4Url = 'https://s3-' + process.env.RegionName + '.amazonaws.com/' + event.mp4Bucket + '/' + key;
      if (key.includes('_360p.mp4')) event.mp4Outputs.mp4_360 = mp4Url;
      if (key.includes('_720p.mp4')) event.mp4Outputs.mp4_720 = mp4Url;
      if (key.includes('_1080p.mp4')) event.mp4Outputs.mp4_1080 = mp4Url;
      if (key.includes('_2160p.mp4')) event.mp4Outputs.mp4_2160 = mp4Url;
      promises.push(validate(event.mp4Bucket, key));
    }
  }

  if (event.frameCapture) {
    event.posterUrls = {};
    let prefix = event.guid + '/thumbnails/';
    promises.push(getposters(event.mp4Bucket,prefix));
  }
  Promise.all(promises)
    .then(() => {
      console.log("Event is ready sending to SNS");
      event.workflowStatus = 'complete';
      event.EndTime = moment().utc().format('YYYY-MM-DD HH:mm.S');
      callback(null, event);
    })
    .catch(err => {
      error.handler(event, err);
      callback(err);
    });
};
  