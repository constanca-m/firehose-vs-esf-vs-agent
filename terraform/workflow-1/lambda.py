import urllib.parse
import boto3
import gzip


def lambda_handler(event, context):
    s3 = boto3.client('s3')
    firehose = boto3.client('firehose')

    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        obj = s3.get_object(Bucket=bucket, Key=key)
        print(f"Object is {obj}")
    except Exception as e:
        print('Error getting object {} from bucket {}.'.format(key, bucket))
        raise e

    delivery_stream = "benchmarking-firehose-ds"
    try:
        with gzip.GzipFile(fileobj=obj["Body"]) as gzipfile:
            content = gzipfile.read()

        response = firehose.put_record(
            DeliveryStreamName=delivery_stream,
            Record={'Data': content}
        )
        print(f"Response of putting record in delivery stream is {response}")
    except Exception as e:
        print('Error putting object {} in delivery stream {}.'.format(key, delivery_stream))
        raise e
