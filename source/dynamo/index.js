 'use strict';
 const AWS = require('aws-sdk');
 const error = require('./lib/error.js');

 exports.handler = (event, context, callback) => {
     console.log('Received event:', JSON.stringify(event, null, 2));

     const docClient = new AWS.DynamoDB.DocumentClient({
         region: process.env.AWS_REGION
     });

     let guid = event.guid;
     delete event.guid;
     let expression = '';
     let values = {};
     let i = 0;

     Object.keys(event).forEach(function(key) {
         i++;
         expression += ' ' + key + ' = :' + i + ',';
         values[':' + i] = event[key];
     });

     let params = {
         TableName: process.env.DynamoDBTable,
         Key: {
             guid: guid,
         },
         // remove the trailing ',' from the update expression added by the forEach loop
         UpdateExpression: 'set ' + expression.slice(0, -1),
         ExpressionAttributeValues: values
     };
     console.log('Dynamo update: ', JSON.stringify(params, null, 2));

     docClient.update(params).promise()
       .then(() => {
           event.guid = guid;
           callback(null, event);
       })
       .catch(err => {
           error.handler(event, err);
           callback(err);
       });
 };
