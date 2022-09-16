import json
import boto3
client=boto3.client('lambda')

def lambda_handler(event, context):
    List = (event['Mylist'])
    print ('First function says:\nList item: {}\nKey value: {}'.format(List[1], event['First']))
    client.invoke(
        FunctionName='Function2',
        InvocationType='Event',
        ClientContext='string',
        Payload= json.dumps(event),
    )

