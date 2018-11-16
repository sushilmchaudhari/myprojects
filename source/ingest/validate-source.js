
'use strict';
const AWS = require('aws-sdk');
const error = require('./lib/error.js');

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const s3 = new AWS.S3();

  function validate(key) {
    let response = new Promise((res, reject) => {
      let params = {
        Bucket: event.srcBucket,
        Key: key
      };
      s3.headObject(params, function(err, data) {
        if (err) reject('error: ',key,' not found');
        else {
          res(data);
        }
      });
    });
    return response;
  }

  let promises = [];

  promises.push(validate(event.srcVideo));

  if (event.ImageOverlay) {
    promises.push(validate('image-overlay/' + event.ImageOverlay));
  }

  Promise.all(promises)
    .then(() => callback(null, event))
    .catch(err => {
      error.handler(event, err);
      callback(err);
    });
};
