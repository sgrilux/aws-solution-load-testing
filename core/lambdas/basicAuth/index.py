import boto3
import base64
import logging


# Setup the logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

ssm_client = boto3.client("ssm", "us-east-1")

# Environment variable are not supported in lambda@edge so we hard code the path here.
user = "/load-testing/basic-auth-user"
password = "/load-testing/basic-auth-password"


def get_parameter(parameter_name):
    response = ssm_client.get_parameter(Name=parameter_name, WithDecryption=True)
    return response["Parameter"]["Value"]


def handler(event, context):
    # Replace 'USERNAME' and 'PASSWORD' with the actual username and password
    USERNAME = get_parameter(user)
    PASSWORD = get_parameter(password)

    # Encode the username and password
    expected_auth = f"{USERNAME}:{PASSWORD}"
    expected_auth_base64 = base64.b64encode(expected_auth.encode()).decode()

    # Get the request from the CloudFront event
    request = event["Records"][0]["cf"]["request"]

    # Check for the Authorization header
    headers = request["headers"]
    auth_header = headers.get("authorization")

    # If no Authorization header is present, or it doesn't match, return 401
    if not auth_header or auth_header[0]["value"] != f"Basic {expected_auth_base64}":
        return {
            "status": "401",
            "statusDescription": "Unauthorized",
            "headers": {
                "www-authenticate": [
                    {"key": "WWW-Authenticate", "value": 'Basic realm="Restricted"'}
                ]
            },
        }

    # If authentication is successful, allow the request to proceed
    return request
