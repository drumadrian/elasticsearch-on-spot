import json
import boto3
import requests
import os

def empty_ecr_repository(repository_name, registryId):
    print ("trying to empty the repository {0}".format(repository_name))
    ecr_client = boto3.client('ecr')
    list_images_response = ecr_client.list_images(registryId=registryId, repositoryName=repository_name)
    if len(list_images_response['imageIds']) == 0:
        print ("ecr_client.list_images() returned 0 images in {0}".format(repository_name))
    else:
        batch_delete_image_response = ecr_client.batch_delete_image(registryId=registryId, repositoryName=repository_name, imageIds=list_images_response['imageIds'])
        #UNCOMMENT THE LINE BELOW TO MAKE LAMBDA DELETE THE REPOSITORY....AND UPDATE IAM POLICY
        # THIS WILL CAUSE AN FAILURE SINCE CLOUDFORMATION ALSO TRIES TO DELETE THE REPOSITORY
        # response = ecr_client.delete_repository(registryId=registryId, repositoryName=repository_name, force=True)
        # print ("Successfully deleted the repository {0}".format(repository_name))
        print ("Successfully emptied the repository {0} of {1} images".format(repository_name, len(list_images_response['imageIds']) ))


def sendResponseCfn(event, context, responseStatus):
    response_body = {'Status': responseStatus,
                    'Reason': 'Log stream name: ' + context.log_stream_name,
                    'PhysicalResourceId': context.log_stream_name,
                    'StackId': event['StackId'],
                    'RequestId': event['RequestId'],
                    'LogicalResourceId': event['LogicalResourceId'],
                    'Data': json.loads("{}")}
    requests.put(event['ResponseURL'], data=json.dumps(response_body))





def lambda_handler(event, context):
    try:
        # bucket = event['ResourceProperties']['ECRRepositoryARN']
        repository_name = os.getenv('repository_name')
        registryId = os.getenv('registryId')
        if event['RequestType'] == 'Delete':
            empty_ecr_repository(repository_name, registryId)
        sendResponseCfn(event, context, "SUCCESS")
    except Exception as e:
        print(e)
        sendResponseCfn(event, context, "FAILED")
