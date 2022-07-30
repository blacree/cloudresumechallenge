import json
import boto3

client = boto3.client('dynamodb')

def lambda_handler(event, context):
    origin = False

    try:
        origin = event['headers']['origin']
        print(origin)
    except:
        pass
    
    if origin:
        if origin == "https://d290w6p20fvvob.cloudfront.net":
            return_headers = {
                "Access-Control-Allow-Origin":'https://d290w6p20fvvob.cloudfront.net',
                "Access-Control-Allow-Headers":'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                "Access-Control-Allow-Methods":"GET, OPTIONS"
            }
        elif origin == "http://crcbucketterraform.s3-website-us-east-1.amazonaws.com":
            return_headers = {
                "Access-Control-Allow-Origin":'http://crcbucketterraform.s3-website-us-east-1.amazonaws.com',
                "Access-Control-Allow-Headers":'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                "Access-Control-Allow-Methods":"GET, OPTIONS"
            }
        else:
            print(event)
            error = {
            "Error":"Access Denied",
            "Reason":"Not Authorized"
            }
            return{
                'statusCode':200,
                'body': json.dumps(error)
            }
            
    else:
        error = {
            "Error":"Access Denied",
            "Reason":"Not Authorized"
        }
        print(event)
        return{
                'statusCode':200,
                'body': json.dumps(error)
            }
        
                
    print(event)
    # print(context.invoked_function_arn)


    update_boolean = "not_instantiated"
    got_parameters = False
    update_parameter_present = False

    try:
        if event["queryStringParameters"]["update"]:
            update_parameter_present = True
            if event["queryStringParameters"]["update"] == "true":
                update_boolean = True
                got_parameters = True
            else:
                if (event["queryStringParameters"]["update"] == "false"):
                    update_boolean = False
                    got_parameters = True
    except:
        pass
    
    if got_parameters:
        try:
            data = client.get_item(
                TableName = 'crc_dynamoDB_table',
                Key={
                "number of views": {
                    "S": "number of page views/refreshes"
                        }
                    }
                )
            current_count = data["Item"]["visit_counter"]["N"]
        except KeyError:
            client.put_item(
                TableName = "crc_dynamoDB_table",
                Item={
                    "number of views": {
                    "S": "number of page views/refreshes"
                    },
                    "visit_counter":{
                        "N": "1"
                    }
                },
                ReturnValues = "NONE"
            )
            return {
                'statusCode':200,
                'headers':return_headers,
                'body': json.dumps("1")
                }

        if update_boolean:
            current_count = int(current_count) + 1
            new_count = {
                "N": str(current_count)
                }
            update_response = client.update_item(
                TableName = 'crc_dynamoDB_table',
                Key={
                    "number of views": {
                    "S": "number of page views/refreshes"
                    }
                },
                ReturnValues='UPDATED_NEW',
                UpdateExpression="set visit_counter=:val1",
                ExpressionAttributeValues={
                    ':val1':new_count
                }
            )
            
            # print(update_response)
            
            return {
                'statusCode':200,
                'headers':return_headers,
                'body': json.dumps(str(current_count))
                }
        else:
            return {
                'statusCode':200,
                'headers':return_headers,
                'body': json.dumps(str(current_count))
                }
    else:
        if update_parameter_present:
            error = {
                "error":'True',
                "parameter":"update",
                "error_details":"Invalid parameter option",
                "possible_options":"true, false"
            }
            return {
            'statusCode':200,
            'headers':return_headers,
            'body': json.dumps(error)
            }
        else:
            error = {
                "error":"True",
                "error_details":"update parameter absent",
                "possible_options":"true, false"
            }
            return{
                'statusCode':200,
                'headers':return_headers,
                'body': json.dumps(error)
            }