# PS5-StickS3 — WebKit Autoloader para M5Stack StickS3

Adaptação do [owendswang/ps5-webkit-autoloader-esp32](https://github.com/owendswang/ps5-webkit-autoloader-esp32) para o **M5Stack StickS3 (ESP32-S3, 8 MB flash)** com tela ST7789 e repositório de payloads.

## 📋 Firmwares Suportados

| Faixa | Exploit | Incluso |
|---|---|---|
| **7.00 — 13.60** | Relapse 🆕 | ✅ |
| **12.00 — 12.70** | P2JB | ✅ (via slopkit, ~3h) |
| **7.00 — 12.00** | Poopsploit | ✅ (via slopkit) |
| **1.00 — 5.50** | umtx2 | ✅ |

O autoloader detecta a firmware automaticamente ou permite escolha manual.

## 🛠️ Build

```bash
# 1. Clone
git clone https://github.com/Matrix-Bebeto/ps5-sticks3
cd ps5-sticks3

# 2. Baixe os payloads essenciais
bash download-payloads.sh essencial

# 3. Configure o ambiente (Arduino CLI, dependencias)
bash setup-environment.sh

# 4. Compile
cd firmware

# Para ESP32-PICO (4MB):
make pico

# Para ESP32-S2:
make s2

# Para ESP32-S3 (StickS3, 4MB - funcional basico):
make s3

# Para StickS3 8MB com tela (em desenvolvimento):
# make sticks3
```

### Grave no StickS3

```bash
# Via esptool.py (USB-C)
esptool.py --chip esp32s3 write_flash 0x0 build/s3/esp32-arduino.s3.merged.bin

# Ou via ESP32 Flash Tool (web):
# https://esp.huhn.me
```

## 📦 Payloads

Execute `bash download-payloads.sh essencial` para baixar:

| Payload | Versão |
|---|---|
| **etaHEN** 2.5B | Homebrew Enabler |
| **kstuff-lite** v1.11 | Kernel patch |
| **elfldr** v0.26 | Carregador ELF |
| **nanoDNS** 0.4 | DNS proxy |
| **ftpsrv** v0.21.1 | Servidor FTP |

Disponíveis (adicione manualmente se couber): ShadowMount, pldmgr, CheatRunner, ps5debug, websrv, ps5upload, web-file-manager, ps5-linux-loader, onionHEN.

> ℹ️ O LittleFS tem ~6,5 MB livres nos 8 MB totais. O etaHEN (4,6 MB) + kstuff-lite (1,7 MB) + elfldr (0,4 MB) ocupam ~6,7 MB — use o script `download-payloads.sh` para selecionar a combinação ideal.

## 🚀 Uso

1. Pluge o StickS3 no PS5
2. Conecte o PS5 ao WiFi `ESP32_PORTAL` (senha `12345678`)
3. No PS5: **Settings → Guide & Tips → User's Guide**
4. O exploit carrega o autoloader e instala o atalho na **Mídia**
5. Após a primeira instalação, o StickS3 não é mais necessário

## 📺 Display ST7789 (135x240) — Em desenvolvimento

O código para a tela está em `firmware/display_sticks3.ino`. Para ativar:

```c
// Compile com as flags:
// -DDISPLAY_ENABLE=1 -DDISPLAY_STICKS3=1
```

**Funcionalidades planejadas:**
- Status do WiFi e conexões
- Lista de payloads navegável pelo botão físico
- Indicador de progresso do exploit
- QR code do WiFi

## 🏗️ Estrutura

```
ps5-sticks3/
├── firmware/                ← Código base (owendswang)
│   ├── esp32-arduino.ino    ← Firmware principal
│   ├── display_sticks3.ino  ← Código da tela ST7789
│   ├── Makefile             ← Build system
│   ├── partitions-8m.csv    ← Particionamento 8 MB
│   └── autoloader/          ← Web assets + exploits
│       └── app/0.5.2/payloads/  ← Payloads ELF aqui
├── scripts/
│   └── configure-sticks3.sh ← Script de config
├── download-payloads.sh     ← Baixa payloads do mirror
├── setup-environment.sh     ← Prepara ambiente
└── README.md
```

## ⚠️ Aviso

Use por sua conta e risco. Mantenha o PS5 offline após o jailbreak e não atualize a firmware.

## 📜 Licenças

- Firmware base: MIT (owendswang/ps5-webkit-autoloader-esp32)
- Exploits: licenças originais de cada projeto
- Código deste repositório: MIT