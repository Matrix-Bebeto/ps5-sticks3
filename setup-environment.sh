#!/usr/bin/env bash
# Prepara ambiente de build para o M5Stack StickS3
# Uso: ./setup-environment.sh

set -e

echo "=== PS5-StickS3: Preparando ambiente ==="
echo ""

# 1. Clona firmware base
if [ ! -d "firmware/.git" ]; then
    echo "[1/4] Clonando firmware base..."
    git clone --depth 1 https://github.com/owendswang/ps5-webkit-autoloader-esp32 firmware_tmp
    # Preserva nossos arquivos custom
    cp -r firmware_tmp/* firmware/
    cp -r firmware_tmp/.git firmware/
    rm -rf firmware_tmp
else
    echo "[1/4] Firmware ja clonado."
fi

# 2. Aplica patches
if [ -d "patches" ]; then
    echo "[2/4] Aplicando patches..."
    for patch in patches/*.patch; do
        if [ -f "$patch" ]; then
            (cd firmware && git apply "../$patch" 2>/dev/null && echo "  Aplicado: $patch" || echo "  Pulando: $patch (ja aplicado?)")
        fi
    done
fi

# 3. Instala dependencias
echo "[3/4] Dependencias..."
if command -v arduino-cli &>/dev/null; then
    echo "  arduino-cli: OK"
else
    echo "  Instale arduino-cli: https://arduino.cc/en/software"
fi
for cmd in curl openssl python3 gzip jq; do
    echo "  $cmd: $(command -v $cmd &>/dev/null && echo OK || echo FALTA)"
done

# 4. Payloads
echo "[4/4] Baixando payloads..."
if [ ! -f "firmware/autoloader/app/0.5.2/payloads/etaHEN_2.5B.bin" ]; then
    ./download-payloads.sh essencial
else
    echo "  Payloads ja existem."
fi

echo ""
echo "=== PRONTO! Compile com: ==="
echo "  cd firmware && make sticks3"