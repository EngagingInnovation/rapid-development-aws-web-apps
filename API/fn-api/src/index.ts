import { APIGatewayProxyHandler, APIGatewayEvent, APIGatewayProxyResult } from "aws-lambda";
import { Logger } from '@aws-lambda-powertools/logger';

const logger = new Logger ({ serviceName: 'aws-webapps-template' });

/**
 * An AWS Lambda function that handles APIGatewayProxyHandler and returns an APIGatewayProxyResult. 
 *
 * @param {APIGatewayEvent} event - the incoming APIGatewayEvent
 * @return {Promise<APIGatewayProxyResult>} the response object containing status code, message, and input
 */
export const handler: APIGatewayProxyHandler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
    /* logging the incoming event would likely mean logging sensitive information. use with care */
    //logger.info('incoming APIGatewayEventrequest', {request: event});

    const currentDate = new Date().toISOString();

    const returnValue = {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Hello, world!',
            datetime: currentDate
        }),
        headers: {
            'content-type': 'application/json',
        },
    };

    logger.info('outgoing APIGatewayProxyResult response', {response: returnValue});
    return returnValue;
};
