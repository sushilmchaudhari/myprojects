'use strict';
const AWS = require('aws-sdk');
const error = require('./lib/error.js');
const fs = require('fs');
const xml2js = require('xml2js');

exports.handler = (event, context, callback) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  const validePresets = [2160, 1080, 720, 540, 360, 270];
  const s3 = new AWS.S3();
  const parser = new xml2js.Parser({
    explicitArray: false
  });

  s3.getObject({
      Bucket: event.srcBucket,
      Key: event.srcMetadataFile
    }).promise()

    .then(data => {
      // XML metadata
      if (data.ContentType.includes('xml')) {
        parser.parseString(data.Body, function(err, data) {
          if (err) throw err;
          else {
            event.srcMetadata = data.Body;
            Object.keys(data.vod).forEach(function(key) {
              event[key] = data.vod[key];
            });
                    if (event.mp4) {
          if (event.mp4.constructor === Array) {
            event.mp4 = event.mp4.map(Number);
          } else {
            event.mp4 = [Number(event.mp4)];
          }
        }
        if (event.hls) {
          if (event.hls.constructor === Array) {
            event.hls = event.hls.map(Number);
          } else {
            event.hls = [Number(event.hls)];
          }
        }
        if (event.dash) {
          if (event.dash.constructor === Array) {
            event.dash = event.dash.map(Number);
          } else {
            event.dash = [Number(event.dash)];
          }
        }
          }
        });
      } else {
        // JSON metadata
        let metadata = JSON.parse(data.Body);
        event.srcMetadata = metadata;
        Object.keys(metadata).forEach(function(key) {
          event[key] = metadata[key];
        });
      }
      // check source metadata for subfolder
      if (event.srcMetadataFile.indexOf('/') > -1) {
        event.srcVideo = event.srcMetadataFile.split("/")[0] + '/' + event.srcVideo;
      }
      // Check the metadata presets match the presets avaible in ETS.
      let presets = [];
      if (event.hls) presets = presets.concat(event.hls);
      if (event.dash) presets = presets.concat(event.dash);
      if (event.mp4) presets = presets.concat(event.mp4);
      presets.forEach(function(p) {
        if (validePresets.indexOf(p) === -1) {
          throw new Error(p + ' is not a valide preset, valide presets are: ' + validePresets);
        }
      });
      callback(null, event);
    })
    .catch(err => {
      error.handler(event, err);
      callback(err);
    });
};
