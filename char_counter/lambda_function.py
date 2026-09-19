import json
import base64

def lambda_handler(event, context):
    try:
        query_params = event.get("queryStringParameters") or {}
        text = query_params.get("string", "")

        if not text and "body" in event:
            body = event["body"]
            if event.get("isBase64Encoded"):
                body = base64.b64decode(body).decode("utf-8")
            text = body

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "input_string": text,
                "character_count": len(text)
            })
        }
    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": str(e)})
        }
