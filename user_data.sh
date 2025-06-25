#!/bin/bash

LOG_FILE="/home/ubuntu/setup.log"
ERR_FILE="/home/ubuntu/setup.err"
PROJECT_DIR="/home/ubuntu/Proyecto_EC2"

# Redirigir stdout y stderr
exec > >(tee -a $LOG_FILE) 2> >(tee -a $ERR_FILE >&2)

echo "🛠️ Iniciando configuración del servidor EC2 - $(date)"

# Actualizar sistema
echo "📦 Actualizando paquetes..."
sudo apt update -y && sudo apt install -y python3-pip git || {
    echo "❌ Error al instalar paquetes base" >&2
    exit 1
}

# Clonar el repositorio
echo "📥 Clonando el repositorio..."
cd /home/ubuntu
git clone https://github.com/jean-franco660/Proyecto_EC2.git || {
    echo "❌ Error al clonar el repositorio" >&2
    exit 1
}

cd $PROJECT_DIR

# Crear archivo .env
echo "🧪 Creando archivo .env..."
cat <<EOF > .env
DYNAMO_TABLE_NAME=reportes_table
REPORT_BUCKET_NAME=${bucket_name}
AWS_REGION=us-east-1
EOF

# Instalar dependencias
echo "📦 Instalando dependencias Python..."
pip3 install -r src/requirements.txt || {
    echo "❌ Error al instalar dependencias Python" >&2
    exit 1
}

# Iniciar Flask
echo "🚀 Iniciando servidor Flask en segundo plano..."
cd src
nohup flask --app app run --host=0.0.0.0 --port=5000 > ../flask_output.log 2>&1 &

# Validar si Flask se está ejecutando
sleep 5
if pgrep -f "flask --app app" > /dev/null; then
    echo "✅ Flask ejecutándose correctamente"
else
    echo "❌ Flask no se está ejecutando. Revisar flask_output.log" >&2
    exit 1
fi

echo "🎉 Configuración finalizada - $(date)"
