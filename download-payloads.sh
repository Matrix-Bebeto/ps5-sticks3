#!/usr/bin/env bash
# Baixa payloads ELF selecionados para o StickS3
# Uso: ./download-payloads.sh [essencial|completo|custom]
set -e

MIRROR="https://github.com/itsPLK/ps5-payloads-mirror/releases/download/payloads-mirror"
DEST="${1:-firmware/autoloader/app/0.5.2/payloads}"
mkdir -p "$DEST"

declare -A PAYLOADS
PAYLOADS[kstuff-lite]="$MIRROR/kstuff-lite_v1.11.elf"
PAYLOADS[etaHEN]="$MIRROR/etaHEN_2.5B.bin"
PAYLOADS[ShadowMount]="$MIRROR/ShadowMountPlus_1.7beta3.elf"
PAYLOADS[elfldr]="$MIRROR/elfldr_v0.26.elf"
PAYLOADS[ftpsrv]="$MIRROR/ftpsrv_v0.21.1.elf"
PAYLOADS[pldmgr]="$MIRROR/pldmgr_v0.5.2.elf"
PAYLOADS[nanoDNS]="$MIRROR/nanoDNS_0.4.elf"
PAYLOADS[CheatRunner]="$MIRROR/CheatRunner_v0.17.2.elf"
PAYLOADS[ps5debug]="$MIRROR/ps5debug-NG_1.3.2.elf"
PAYLOADS[web-file-manager]="$MIRROR/ps5-web-file-manager_v1.10.elf"
PAYLOADS[websrv]="$MIRROR/websrv_v0.34.elf"
PAYLOADS[ps5upload]="$MIRROR/ps5upload_v6.1.2.elf"
PAYLOADS[ps5-linux-loader]="$MIRROR/ps5-linux-loader_v2.5.elf"
PAYLOADS[ps5-app-dumper]="$MIRROR/ps5-app-dumper_v2.10.elf"
PAYLOADS[onionHEN]="$MIRROR/onionHEN_v0.0.13.elf"
PAYLOADS[BFpilot]="$MIRROR/BFpilot_v0.4.4.elf"
PAYLOADS[PKG-Manager]="$MIRROR/PKG-Manager_v1.4.1.elf"
PAYLOADS[garlic-savemgr]="$MIRROR/garlic-savemgr_v1.13.1.elf"

ESCOLHA="${2:-essencial}"

case "$ESCOLHA" in
  essencial)
    LISTA=(etaHEN kstuff-lite elfldr nanoDNS ftpsrv)
    ;;
  completo)
    LISTA=(etaHEN kstuff-lite ShadowMount elfldr pldmgr nanoDNS ftpsrv ps5debug web-file-manager websrv)
    ;;
  custom)
    LISTA=("${@:3}")
    ;;
esac

for nome in "${LISTA[@]}"; do
    url="${PAYLOADS[$nome]}"
    if [ -z "$url" ]; then
        echo "⚠️  Payload '$nome' desconhecido, pulando"
        continue
    fi
    arquivo="$DEST/${url##*/}"
    echo "📥 $nome → $arquivo"
    curl -sL -o "$arquivo" "$url" -w "   HTTP %{http_code} | %{size_download} bytes\n"
done

echo ""
echo "=== CONTEUDO FINAL ==="
ls -lh "$DEST/"
echo ""
du -sh "$DEST/"