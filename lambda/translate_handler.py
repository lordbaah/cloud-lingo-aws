import json
import boto3
import os
import uuid
from datetime import datetime

s3 = boto3.client("s3")
translate = boto3.client("translate")

REQUEST_BUCKET = os.environ["REQUEST_BUCKET"]
RESPONSE_BUCKET = os.environ["RESPONSE_BUCKET"]

def lambda_handler(event, context):
    try:
        # 🔁 Path 1: API Gateway POST (frontend or Postman)
        if "body" in event:
            body = json.loads(event["body"])
            text = body["text"]
            source_lang = body["source_lang"]
            target_lang = body["target_lang"]

            # Generate unique ID and timestamp
            request_id = str(uuid.uuid4())
            timestamp = datetime.utcnow().isoformat()

            # Save input to request bucket
            request_payload = {
                "text": text,
                "source_lang": source_lang,
                "target_lang": target_lang,
                "timestamp": timestamp
            }
            s3.put_object(
                Bucket=REQUEST_BUCKET,
                Key=f"{request_id}.json",
                Body=json.dumps(request_payload),
                ContentType="application/json"
            )

            # Perform translation
            result = translate.translate_text(
                Text=text,
                SourceLanguageCode=source_lang,
                TargetLanguageCode=target_lang
            )

            translated_payload = {
                "original_text": text,
                "translated_text": result["TranslatedText"],
                "source_lang": source_lang,
                "target_lang": target_lang,
                "timestamp": timestamp
            }

            # Save translated output to response bucket
            s3.put_object(
                Bucket=RESPONSE_BUCKET,
                Key=f"translated-{request_id}.json",
                Body=json.dumps(translated_payload),
                ContentType="application/json"
            )

            return {
                "statusCode": 200,
                "body": json.dumps(translated_payload),
                "headers": {
                    "Content-Type": "application/json"
                }
            }

        # 🔁 Path 2: S3 Upload Trigger
        for record in event["Records"]:
            source_bucket = record["s3"]["bucket"]["name"]
            object_key = record["s3"]["object"]["key"]

            # Download the uploaded file
            response = s3.get_object(Bucket=source_bucket, Key=object_key)
            file_content = response["Body"].read().decode("utf-8")
            data = json.loads(file_content)

            text = data["text"]
            source_lang = data["source_lang"]
            target_lang = data["target_lang"]

            # Translate
            result = translate.translate_text(
                Text=text,
                SourceLanguageCode=source_lang,
                TargetLanguageCode=target_lang
            )

            translated_data = {
                "original_text": text,
                "translated_text": result["TranslatedText"],
                "source_lang": source_lang,
                "target_lang": target_lang
            }

            # Save to response bucket
            output_key = f"translated-{os.path.basename(object_key)}"
            s3.put_object(
                Bucket=RESPONSE_BUCKET,
                Key=output_key,
                Body=json.dumps(translated_data),
                ContentType="application/json"
            )

            print(f"Translation (S3) successful: {output_key}")

    except Exception as e:
        print("Error:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
            "headers": {"Content-Type": "application/json"}
        }
