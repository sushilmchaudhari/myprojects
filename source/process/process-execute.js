'use strict';
const AWS = require('aws-sdk');
const error = require('./lib/error.js');

exports.handler = (event, context, callback) => {
    console.log('Received event:', JSON.stringify(event, null, 2));

    const stepfunctions = new AWS.StepFunctions({
        region: process.env.AWS_REGION
    });

    let params = {
        stateMachineArn: process.env.ProcessWorkflow,
        input: JSON.stringify({"guid":event.guid}),
        name: event.guid
    };

    console.log('workflow execute: ',JSON.stringify(params, null, 2));

    stepfunctions.startExecution(params).promise()
      .then(() => callback(null, 'success'))
      .catch(err => {
        error.handler(event, err);
        callback(err);
      });

};
