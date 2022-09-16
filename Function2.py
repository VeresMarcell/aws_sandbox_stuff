import json

def lambda_handler(event, context):
    List = (event['Mylist'])
    print ('Second function says:\nList item: {}\nKey value: {}'.format(List[2], event['Second']))