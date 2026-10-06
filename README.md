# PS5-StickS3 — WebKit Autoloader + Display + Payload Repository

Firmware adaptado do [owendswang/ps5-webkit-autoloader-esp32](https://github.com/owendswang/ps5-webkit-autoloader-esp32) para **M5Stack StickS3 (ESP32-S3, 8 MB flash)** com tela ST7789, botão físico e todos os exploits/payloads embutidos.

## 📋 Firmwares Suportados

| Firmware | Exploit | Incluso |
|---|---|---|
| **7.00 — 13.60** 🆕 | Relapse ✅ | Rápido (segundos) |
| **12.00 — 12.70** | P2JB ✅ | Lento (3h, incluso no slopkit) |
| **9.00 — 12.00** | Poopsploit ✅ | Rápido |
| **1.00 — 5.50** | umtx2 ✅ | Suporte limitado |

O autoloader detecta automaticamente a firmware e usa o exploit correto. Você também escolhe manualmente na interface.

## 🛠️ O que você precisa

### Hardware
| Item | Especificação |
|---|---|
| **M5Stack StickS3** | ESP32-S3, 8 MB flash, tela ST7789 (135x240) |
| **Cabo USB-C** | Para conectar ao PS5 ou PC |
| **PS5** | Firmware 7.00–13.60 |

### Software
```bash
# 1. Ambiente
sudo apt install curl git python3 openssl jq
# Arduino CLI: https://arduino.cc/en/software
# Arduino ESP32 core 2.0.11

# 2. Clone
git clone --recursive https://github.com/seu-usuario/ps5-sticks3
cd ps5-sticks3

# 3. Configure
bash setup-environment.sh

# 4. Compile
cd firmware && make sticks3

# 5. Grave no StickS3
# Via USB-C usando ESP32 Flash Tool ou esptool.py:
python3 esptool.py --chip esp32s3 write_flash 0x0 build/s3/esp32-arduino.s3.merged.bin
```

## 📺 O que aparece na tela

```
┌──────────────────────────────┐
│  🔵 PS5 AUTOLOADER v0.5.2   │
│                              │
│  📡 ESP32_PORTAL             │
│  🔑 12345678                 │
│  🌐 192.168.4.1              │
│  👥 0 Conectados             │
│                              │
│  Aperte botao p/ navegar     │
│  pelos payloads              │
└──────────────────────────────┘
```

### Navegação
| Ação | Função |
|---|---|
| 1 clique | Alterna entre telas / payloads |
| 2 cliques | Envia payload selecionado |
| Segurar | Reset / Info |

## 📦 Payloads Inclusos

| Payload | Versão | Tamanho | Essencial? |
|---|---|---|---|
| **etaHEN** 2.5B | Homebrew Enabler | 4.6 MB | ✅ |
| **kstuff-lite** v1.11 | Kernel patch leve | 1.7 MB | ✅ |
| **elfldr** v0.26 | Carregador ELF | 385 KB | ✅ |
| **nanoDNS** 0.4 | DNS proxy | 129 KB | ✅ |
| **ftpsrv** v0.21.1 | Servidor FTP | 187 KB | |
| **pldmgr** v0.5.2 | Payload Manager | 2.4 MB | |
| **ShadowMountPlus** 1.7β3 | Auto-mounter FPKG | 2.4 MB | |
| **CheatRunner** v0.17.2 | Trainers | 9.8 MB | |
| **ps5debug-NG** 1.3.2 | Debug settings | 4.0 MB | |
| **websrv** v0.34 | Web server | 1.6 MB | |

**Espaço total LittleFS:** ~6,5 MB → Selecione os que cabem.

### Baixar payloads
```bash
# Essenciais (recomendado): etaHEN + kstuff + elfldr + nanoDNS + ftpsrv
./download-payloads.sh essencial

# Completo (pode nao caber todo)
./download-payloads.sh completo
```

## 🚀 Uso

1. **Pluga** o StickS3 no PS5 (qualquer porta USB)
2. **Liga** o PS5
3. StickS3 liga sozinho (5V pela USB) e cria o WiFi `ESP32_PORTAL`
4. No PS5: **Settings → Network → Settings → Set Up Internet Connection → Use Wi-Fi**
5. Conecta no `ESP32_PORTAL` (senha `12345678`)
6. **Settings → Guide & Tips → User's Guide**
7. O exploit carrega e instala o atalho na **Mídia**
8. Depois disso o **StickS3 não é mais necessário** — o atalho fica no PS5

## 📡 Cloudflare Tunnel (opcional)

Use o StickS3 como servidor de payloads externo via Cloudflare Tunnel:

```yaml
# No cloudflared config
ingress:
  - hostname: ps5.matrixwifi.com.br
    service: http://127.0.0.1:4000
```

## 🏗️ Estrutura do Projeto

```
ps5-sticks3/
├── firmware/              ← Código base (submodule do repo original)
├── patches/               ← Patches para o firmware
├── scripts/               ← Scripts auxiliares
├── download-payloads.sh   ← Baixa payloads ELF
├── setup-environment.sh   ← Prepara ambiente de build
└── README.md
```

## 🧠 Como funciona

```
StickS3 ──📡── WiFi AP ──📶── PS5
  │                            │
  ├── HTTPS server (443)       ├── User's Guide → carrega exploit
  ├── HTTP server (80)         ├── Payload Manager → lista ELFs
  ├── DNS server (53)          └── Conexão automática
  ├── ST7789 Display (135×240)
  └── Botão físico (navegação)
```

## ⚠️ Aviso

Use por sua conta e risco. Mantenha o PS5 offline após o jailbreak e nunca atualize a firmware.

## 📜 Licenças

- Firmware base: MIT (owendswang/ps5-webkit-autoloader-esp32)
- Exploits: Licenças originais de cada projeto (Relapse, slopkit, umtx2)
- Código deste repositório: MIT
- Payloads: licenças dos respectivos autores