from flask import Flask, jsonify
import boto3
import json
import os
from dotenv import load_dotenv

# Cargar variables del archivo .env
load_dotenv()

app = Flask(__name__)

# Configuración desde variables de entorno
BUCKET_NAME = os.environ.get("REPORT_BUCKET_NAME")
TABLE_NAME = os.environ.get("DYNAMO_TABLE_NAME")
REGION = os.environ.get("AWS_REGION", "us-east-1")

# Clientes AWS
s3 = boto3.client('s3', region_name=REGION)
dynamodb = boto3.resource('dynamodb', region_name=REGION)
table = dynamodb.Table(TABLE_NAME)

@app.route("/")
def home():
    return "✅ Servidor Flask activo en EC2"

@app.route("/reportes")
def listar_reportes():
    try:
        response = table.scan()
        reportes = response.get("Items", [])
        return jsonify(reportes)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
