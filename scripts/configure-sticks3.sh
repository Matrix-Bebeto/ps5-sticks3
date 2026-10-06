#!/usr/bin/env bash
# Cria link entre o firmware original e nossa config
# Rode DENTRO do diretorio firmware/
set -e

echo "Aplicando config M5Stack StickS3..."

# 1. Usar particionamento 8MB
cp partitions-8m.csv partitions.csv

# 2. Criar payload_map.js com a lista de payloads disponiveis
cat > autoloader/app/0.5.2/payload_map.js << 'MAPEOF'
// Mapa de payloads para o Payload Manager do StickS3
// Gerado automaticamente - liste aqui os .elf que voce colocou em payloads/
window.PAYLOAD_MAP = {
  "kstuff": {
    "version": "v1.6.7",
    "file": "kstuff_v1.6.7.elf",
    "desc": "Kernel patch - essencial para FPKGs"
  },
  "kstuff-lite": {
    "version": "v1.11",
    "file": "kstuff-lite_v1.11.elf",
    "desc": "Kernel patch versao leve"
  },
  "etaHEN": {
    "version": "2.5B",
    "file": "etaHEN_2.5B.bin",
    "desc": "Homebrew Enabler completo"
  },
  "ShadowMount": {
    "version": "1.7beta3",
    "file": "ShadowMountPlus_1.7beta3.elf",
    "desc": "Montador automatico de FPKGs"
  },
  "elfldr": {
    "version": "v0.26",
    "file": "elfldr_v0.26.elf",
    "desc": "Carregador de ELFs (porta 9021)"
  },
  "pldmgr": {
    "version": "v0.5.2",
    "file": "pldmgr_v0.5.2.elf",
    "desc": "Gerenciador de payloads com Web UI"
  },
  "ftpsrv": {
    "version": "v0.21.1",
    "file": "ftpsrv_v0.21.1.elf",
    "desc": "Servidor FTP (porta 2121)"
  },
  "nanoDNS": {
    "version": "0.4",
    "file": "nanoDNS_0.4.elf",
    "desc": "Servidor DNS local"
  },
  "CheatRunner": {
    "version": "v0.17.2",
    "file": "CheatRunner_v0.17.2.elf",
    "desc": "Trainers para jogos"
  },
  "ps5debug": {
    "version": "1.3.2",
    "file": "ps5debug-NG_1.3.2.elf",
    "desc": "Debug settings do PS5"
  },
  "web-file-manager": {
    "version": "v1.10",
    "file": "ps5-web-file-manager_v1.10.elf",
    "desc": "Gerenciar arquivos via navegador"
  },
  "ps5upload": {
    "version": "v6.1.2",
    "file": "ps5upload_v6.1.2.elf",
    "desc": "Transferencia rapida PC→PS5"
  }
};
MAPEOF
echo "  payload_map.js criado"

# 3. Adicionar display.ino com o codigo da tela ST7789
if [ ! -f "display_sticks3.ino" ]; then
    cat > display_sticks3.ino << 'DISPEOF'
/*
 * display_sticks3.ino - Tela LCD ST7789 para M5Stack StickS3
 * Driver: ST7789P3, resolucao 135x240, SPI
 * Pinos StickS3: MOSI=GPIO2, SCK=GPIO3, RS=GPIO5, CS=GPIO6, RST=GPIO7, BL=GPIO9
 * 
 * Inclua este arquivo no mesmo diretorio do esp32-arduino.ino
 * e compile com -DDISPLAY_ENABLE=1 -DDISPLAY_STICKS3=1
 */

#ifdef DISPLAY_ENABLE
#include <SPI.h>
#include <TFT_eSPI.h>

TFT_eSPI tft = TFT_eSPI(135, 240);

// Configuracao de pinos para StickS3
#ifdef DISPLAY_STICKS3
  #define TFT_MOSI 2
  #define TFT_SCK  3
  #define TFT_CS   6
  #define TFT_RS   5
  #define TFT_RST  7
  #define TFT_BL   9
#endif

#define BOTAO_PIN 0  // Botao do StickS3 no GPIO0 (confirmar)
#define BOTAO2_PIN 14  // Segundo botao (GPIO14)

// Estados da UI
enum DisplayState {
  DISPLAY_BOOT,
  DISPLAY_WIFI,
  DISPLAY_WAITING,
  DISPLAY_PS5_CONNECTED,
  DISPLAY_PAYLOAD_LIST,
  DISPLAY_EXPLOIT_RUNNING,
  DISPLAY_SUCCESS,
  DISPLAY_ERROR
};

DisplayState currentState = DISPLAY_BOOT;
int selectedPayload = 0;
String statusMessage = "";
int totalConnections = 0;
bool buttonPressed = false;
uint32_t lastButtonPress = 0;

void initDisplay() {
  pinMode(TFT_BL, OUTPUT);
  digitalWrite(TFT_BL, HIGH); // Backlight ON
  
  tft.init();
  tft.setRotation(1); // 240x135 paisagem
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setTextSize(1);
}

void drawBootScreen() {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.setTextSize(2);
  tft.setCursor(10, 10);
  tft.println("PS5 AUTOLOADER");
  tft.setTextSize(1);
  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.setCursor(10, 35);
  tft.println("StickS3 v0.5.2");
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setCursor(10, 55);
  tft.println("Iniciando...");
  currentState = DISPLAY_WIFI;
}

void drawWifiScreen() {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_YELLOW, TFT_BLACK);
  tft.setTextSize(1);
  tft.setCursor(5, 5);
  tft.println("WiFi: ESP32_PORTAL");
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setCursor(5, 20);
  tft.println("IP: 192.168.4.1");
  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.setCursor(5, 40);
  tft.print("Conectados: ");
  tft.println(totalConnections);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setCursor(5, 60);
  tft.println("PS5: Settings > Guide");
  tft.setCursor(5, 75);
  tft.println("  > User's Guide");
  tft.setTextColor(TFT_DARKGREY, TFT_BLACK);
  tft.setCursor(5, 100);
  tft.println("Botao: selecionar payload");
}

void drawPayloadList() {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.setTextSize(1);
  tft.setCursor(5, 5);
  tft.println("== Payloads ==");
  
  // Lista de payloads (simplificada - a real vem do HTML)
  const char* payloadNames[] = {"etaHEN", "kstuff", "ShadowMount", "elfldr", "pldmgr", "ftpsrv", "nanoDNS"};
  int count = 7;
  
  for (int i = 0; i < count && i < 8; i++) {
    tft.setCursor(5, 20 + i * 14);
    if (i == selectedPayload) {
      tft.setTextColor(TFT_GREEN, TFT_BLACK);
      tft.print("> ");
    } else {
      tft.setTextColor(TFT_WHITE, TFT_BLACK);
      tft.print("  ");
    }
    tft.println(payloadNames[i]);
  }
  
  tft.setTextColor(TFT_DARKGREY, TFT_BLACK);
  tft.setCursor(5, 130);
  tft.println("Duplo clique: envia p/ PS5");
}

void updateDisplay() {
  switch (currentState) {
    case DISPLAY_BOOT:
      drawBootScreen();
      break;
    case DISPLAY_WIFI:
      drawWifiScreen();
      break;
    case DISPLAY_PAYLOAD_LIST:
      drawPayloadList();
      break;
  }
}

void handleButton() {
  bool btnState = digitalRead(BOTAO_PIN) == LOW;
  uint32_t now = millis();
  
  if (btnState && !buttonPressed && (now - lastButtonPress) > 300) {
    buttonPressed = true;
    lastButtonPress = now;
    
    if (currentState == DISPLAY_WIFI) {
      currentState = DISPLAY_PAYLOAD_LIST;
      selectedPayload = 0;
    } else if (currentState == DISPLAY_PAYLOAD_LIST) {
      selectedPayload = (selectedPayload + 1) % 7;
    }
    updateDisplay();
  }
  
  // Botao duplo clique = enviar payload
  static uint32_t lastClickTime = 0;
  if (btnState && (now - lastClickTime) < 500 && (now - lastClickTime) > 50) {
    // Envia payload selecionado
    tft.fillScreen(TFT_GREEN);
    tft.setTextColor(TFT_WHITE, TFT_BLACK);
    tft.setCursor(20, 60);
    tft.println("ENVIANDO...");
    delay(2000);
    currentState = DISPLAY_WIFI;
    updateDisplay();
  }
  if (btnState) lastClickTime = now;
  
  if (!btnState) buttonPressed = false;
}
DISPEOF
    echo "  display_sticks3.ino criado"
fi

echo ""
echo "Feito! Compile com:"
echo "  cd firmware && make sticks3"