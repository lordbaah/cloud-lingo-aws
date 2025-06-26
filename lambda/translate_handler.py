import json
import boto3
import os

s3 = boto3.client("s3")
translate = boto3.client("translate")
RESPONSE_BUCKET = os.environ["RESPONSE_BUCKET"]

def lambda_handler(event, context):
    # Get the uploaded file details
    for record in event["Records"]:
        source_bucket = record["s3"]["bucket"]["name"]
        object_key = record["s3"]["object"]["key"]

        # Download the file from S3
        response = s3.get_object(Bucket=source_bucket, Key=object_key)
        file_content = response["Body"].read().decode("utf-8")

        try:
            data = json.loads(file_content)
            text = data["text"]
            source_lang = data["source_lang"]
            target_lang = data["target_lang"]

            # Perform translation
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

            # Save translated result to response bucket
            output_key = f"translated-{os.path.basename(object_key)}"
            s3.put_object(
                Bucket=RESPONSE_BUCKET,
                Key=output_key,
                Body=json.dumps(translated_data),
                ContentType="application/json"
            )

            print(f"Translation successful: {output_key}")
        except Exception as e:
            print(f"Error processing file {object_key}: {str(e)}")
            raise e
