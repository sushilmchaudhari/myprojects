'use strict';
const AWS = require('aws-sdk');

let errPromise = function(event, _err) {
  console.log('Running Error Handler');

  const lambda = new AWS.Lambda({
    region: process.env.AWS_REGION
  });

  let params;

  let payload = {
    "guid": event.guid,
    "event": event,
    "function": process.env.AWS_LAMBDA_FUNCTION_NAME,
    "error": _err.toString()
  };

  params = {
    FunctionName: process.env.ErrorHandler,
    Payload: JSON.stringify(payload, null, 2)
  };
  lambda.invoke(params).promise()
    .catch(err => console.log(err));
};
module.exports = {
  handler: errPromise
};
