import logging
import json
import azure.functions as func
import os
from azure.core.exceptions import (
    ClientAuthenticationError,
    HttpResponseError,
    ServiceRequestError,
    ResourceNotFoundError,
    AzureError
)
from azure.data.tables import TableClient, TableServiceClient, UpdateMode
from datetime import datetime


def create_table_and_entity(connection_string):
    # Create table
    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
    table_name = "noofviews"
    table_service_client.create_table(table_name=table_name)

    # Create entity
    entity = {
        "PartitionKey": "counter",
        "RowKey" : "counter_value",
        "Date_of_creation": str(datetime.now()),
        "Description": "The no of times your web page has been visited",
        "no" : 1
    }
    table_client = table_service_client.get_table_client(table_name=table_name)
    table_client.create_entity(entity=entity)
    return("[+] Done")



# def main(req: func.HttpRequest, crcCosmodbResponse) -> func.HttpResponse:
def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    the_connection_string = os.getenv("CRC_COSMODB_CS")
    return_headers = {"Access-Control-Allow-Origin":"https://crcstorage2023.blob.core.windows.net"}
    
    if req.headers.get('origin') ==  "https://crcstorage2023.blob.core.windows.net":
        # for key, value in req.headers.items():
        #     logging.info(f"{key} : {value}")
        # for key, value in req.params.items():
            # logging.info(f"{key}: {value}")
    
        request_parameter = req.params.get('update')
        if not request_parameter:
            try:
                req_body = req.get_json()
            except ValueError:
                pass
            else:
                request_parameter = req_body.get('update')

        if request_parameter:
            if request_parameter.lower() == "false":
                # logging.info(f"{crcCosmodbResponse}")
                # Query table and get counter value
                try:
                    table_client = TableClient.from_connection_string(conn_str=the_connection_string, table_name="noofviews")
                    filter = "Description eq 'The no of times your web page has been visited'"
                    entities = table_client.query_entities(filter)
                    for entity in entities:
                        for key in entity.keys():
                            if key == 'no':
                                return func.HttpResponse(f"{entity[key]}", status_code=200, headers=return_headers)
                except ResourceNotFoundError:
                    create_table_result = create_table_and_entity(the_connection_string)
                    if create_table_result == "[+] Done":
                        return func.HttpResponse("1", status_code=200)
            elif request_parameter.lower() == "true":
                try:
                    # Connect to crc cosmodb table            
                    table_client = TableClient.from_connection_string(conn_str=the_connection_string, table_name="noofviews")
                    table_entity = table_client.get_entity(partition_key="counter", row_key="counter_value")
                    new_counter = table_entity["no"] + 1
                    table_entity["no"] = new_counter
                    table_client.update_entity(mode=UpdateMode.REPLACE, entity=table_entity)

                    # Return updated counter value
                    return func.HttpResponse(f"{new_counter}", status_code=200, headers=return_headers)
                except ResourceNotFoundError:
                    create_table_result = create_table_and_entity(the_connection_string)
                    if create_table_result == "[+] Done":
                        return func.HttpResponse("1", status_code=200)
            else:
                # error = f"error:True \nerror_details:Invalid option for update query parameter \npossible_options:true, false"
                error = {"error":"True", "error_details":"Invalid option for update query parameter", "possible_options":"true, false"}
                return func.HttpResponse(json.dumps(error), status_code=200, headers=return_headers, mimetype="application/json")
        else:
            # error = f"error:True \nerror_details:update query parameter absent \npossible_options:true, false"
            error = {"error":"True", "error_details":"update query parameter absent", "possible_options":"true, false"}
            return func.HttpResponse(json.dumps(error), status_code=200, headers=return_headers, mimetype="application/json")
    else:
        return_headers = {"Content-Type":"application/json"}
        invalid_requset = {"error": "True", "Reason":"You are not Authorized to access this API"}
        return func.HttpResponse(json.dumps(invalid_requset), headers=return_headers)
        #return func.HttpResponse(json.dumps(invalid_requset), mimetype="application/json")

# {
#       "name":"crcCosmodbResponse",
#       "type": "table",
#       "tableName": "noofviews",
#       "partitionKey": "counter",
#       "rowKey": "counter_value",
#       "connection": "CRC_COSMODB_CS",
#       "direction": "in"
#     }