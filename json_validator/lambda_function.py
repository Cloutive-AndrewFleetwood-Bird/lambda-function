import json
import base64

def lambda_handler(event, context):
    try:
        body = event.get("body", "")
        if event.get("isBase64Encoded"):
            body = base64.b64decode(body).decode("utf-8")
            
        if not body:
            return {
                "statusCode": 400,
                "body": json.dumps({"valid": False, "message": "Empty body provided"})
            }

        json.loads(body)
        
        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"valid": True, "message": "Valid JSON string"})
        }
    except ValueError as e:
        return {
            "statusCode": 400,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"valid": False, "message": f"Invalid JSON: {str(e)}"})
        }
