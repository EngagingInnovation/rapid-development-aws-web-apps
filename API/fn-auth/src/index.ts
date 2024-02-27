import { APIGatewayRequestAuthorizerEventV2, APIGatewaySimpleAuthorizerWithContextResult } from 'aws-lambda'
import { Logger } from '@aws-lambda-powertools/logger';

const logger = new Logger({ serviceName: 'aws-webapps-template' });

interface contextAuth2 {
    userId: string;
    email: string;
};

/**
 * An AWS Lambda function handler for API Gateway authorization event, APIGatewayRequestAuthorizerEventV2
 *
 * @param {APIGatewayRequestAuthorizerEventV2} authorizerEventV2 - the incoming event
 * @return {Promise<APIGatewaySimpleAuthorizerWithContextResult<contextAuth2>>} the authorization result
 */
export const handler = async (authorizerEventV2: APIGatewayRequestAuthorizerEventV2): Promise<APIGatewaySimpleAuthorizerWithContextResult<contextAuth2>> => {
    logger.info('APIGatewayRequestAuthorizerEventV2 incoming event', { event: authorizerEventV2 });
    const authorizationHeader = authorizerEventV2.headers?.['authorization']

    const response: APIGatewaySimpleAuthorizerWithContextResult<contextAuth2> = {
        isAuthorized: false,
        context: {
            userId: '999',
            email: 'noAuth'
        }
    }

    if (!authorizationHeader) {
        logger.info('APIGatewaySimpleAuthorizerWithContextResult return value', { response: response })
        return response
    }

    const encodedCredentials = authorizationHeader.split(' ')[1];
    const [email, password] = Buffer.from(encodedCredentials, 'base64').toString('utf-8').split(':');
    const isValid = await validateCredentials(email, password, response.context);

    if (isValid) {
        response.isAuthorized = true
    }

    logger.info('return', { response: response })
    return response
};

/**
 * Validate the provided credentials for a user.
 *
 * @param {string} username - The username from auth header
 * @param {string} password - The password from auth header
 * @param {contextAuth2} userObj - The user object to update with email and user ID
 * @return {Promise<boolean>} Whether the credentials are valid or not
 */
const validateCredentials = async (username: string, password: string, userObj: contextAuth2): Promise<boolean> => {

    // check that the username looks like an email
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!regex.test(username)) {
        userObj.email = 'badEmail'
        return false;
    }

    // for this basic example, we're simply checking if the username is the same as the password
    if (username != password) {
        userObj.email = 'badAuth'
        return false;
    } else {
        userObj.email = username
    }

    // check for "username" in a comma separated list defined by ALLOWED_USER
    if (process.env.ALLOWED_USERS) {
        const allowedUsers = process.env.ALLOWED_USERS.split(',');
        if (!allowedUsers.includes(username)) {
            userObj.email = 'badAccess'
            return false;
        }
    } else {
        logger.error('process.env.ALLOWED_USERS not set')
        userObj.email = "nobodyAllowed"
        return false
    }

    // we passed all the tests! this user gets to use the api
    const userAllowed: boolean = true;
    userObj.userId = '111'

    return userAllowed;
};
