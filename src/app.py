# src/app.py
from flask import Flask, jsonify
import boto3
import json
import os

app = Flask(__name__)

# Configura el cliente S3
s3 = boto3.client('s3')
BUCKET_NAME = os.environ.get("REPORT_BUCKET_NAME", "proyecto-reportes-procesados")

@app.route("/reportes")
def listar_reportes():
    try:
        archivos = s3.list_objects_v2(Bucket=BUCKET_NAME)
        if 'Contents' not in archivos:
            return jsonify({"message": "No hay reportes disponibles."})

        reportes = []
        for obj in archivos['Contents']:
            key = obj['Key']
            if key.endswith(".json"):
                contenido = s3.get_object(Bucket=BUCKET_NAME, Key=key)
                data = json.loads(contenido['Body'].read().decode('utf-8'))
                reportes.append({
                    "archivo": key,
                    "reporte": data
                })
        return jsonify(reportes)

    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
