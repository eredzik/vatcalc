import boto3
import logging
from botocore.exceptions import ClientError
from fastapi import HTTPException

class S3Events(object):

    def __init__(self, aws_access_key_id, aws_secret_access_key):

        self.aws_access_key_id = aws_access_key_id
        self.aws_secret_access_key = aws_secret_access_key
        self.session = boto3.Session(
            aws_access_key_id=self.aws_access_key_id,
            aws_secret_access_key=self.aws_secret_access_key,
        )
        self.s3 = self.session.resource('s3')

    def upload(self, file_name=None, bucket=None, key=None):

        """Upload a file to an S3 bucket
        :param key: The name of the key to upload to
        :param file_name: File to upload
        :param bucket: Bucket to upload to
        :return: True if file was uploaded, else False
        """

        # If S3 object_name was not specified, use file_name
        if (key is None) or (bucket is None):
            raise HTTPException(status_code=401, detail="key and bucket cannot be None")

        # Upload the file
        s3_client = boto3.client('s3')
        try:
            response = s3_client.upload_file(file_name, bucket, key, ExtraArgs={'ACL': 'public-read'})
        except ClientError as e:
            raise HTTPException(status_code=401, detail=f"INFO: Failed to upload file! Error: {e}")

        object_url = s3_client.generate_presigned_url('get_object', ExpiresIn=0, Params={'Bucket': bucket, 'Key': key})
        return object_url
