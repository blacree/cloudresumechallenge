import json

def lambda_handler(event, context):
    # TODO implement
    
    try:
        if event['Records']:
            print(event)
            # print(context.invoked_function_arn)
    except:
        pass