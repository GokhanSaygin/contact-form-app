import json
import boto3
import os
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

def lambda_handler(event, context):
    try:
        # API Gateway'den gelen veriyi al
        body = json.loads(event['body'])

        name    = body.get('name', '')
        email   = body.get('email', '')
        message = body.get('message', '')

        # Basit validasyon
        if not name or not email or not message:
            return {
                'statusCode': 400,
                'headers': cors_headers(),
                'body': json.dumps({'error': 'All fields are required'})
            }

        # DynamoDB'ye kaydet
        item = {
            'id':        str(uuid.uuid4()),  # Benzersiz ID üret
            'name':      name,
            'email':     email,
            'message':   message,
            'createdAt': datetime.utcnow().isoformat()
        }

        table.put_item(Item=item)

        return {
            'statusCode': 200,
            'headers': cors_headers(),
            'body': json.dumps({'message': 'Form submitted successfully!'})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': cors_headers(),
            'body': json.dumps({'error': str(e)})
        }

def cors_headers():
    return {
        'Access-Control-Allow-Origin':  '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS'
    }