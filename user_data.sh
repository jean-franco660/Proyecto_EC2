#!/bin/bash

# Actualizar sistema
sudo apt update -y
sudo apt install -y python3-pip git

# Clonar el repositorio
cd /home/ubuntu
git clone https://github.com/jean-franco660/Proyecto_EC2.git
cd Proyecto_EC2

# Crear archivo .env
cat <<EOF > .env
DYNAMO_TABLE_NAME=reportes_table
REPORT_BUCKET_NAME=proyecto-reportes-procesados
AWS_REGION=us-east-1
EOF

# Instalar dependencias
pip3 install -r requirements.txt

# Ejecutar la app Flask en segundo plano
nohup python3 app.py > log.txt 2>&1 &
