/*
 * display_sticks3.ino - Tela ST7789 para M5Stack StickS3
 * Compila junto com esp32-arduino.ino quando DISPLAY_ENABLE=1
 * 
 * Driver: ST7789P3 | Resolucao: 135x240 | SPI
 * Pinos: MOSI=2, SCK=3, RS=5, CS=6, RST=7, BL=9
 * Botoes: GPIO0 (principal), GPIO14 (secundario)
 */

#ifdef DISPLAY_ENABLE

#include <TFT_eSPI.h>

TFT_eSPI tft = TFT_eSPI(135, 240);

// Estados globais
volatile DisplayState currentState = DISPLAY_BOOT;
volatile int selectedPayload = 0;
int totalConnections = 0;
bool buttonPressed = false;
uint32_t lastButtonPress = 0;
uint32_t lastClickTime = 0;

static const char* payloadNames[] = {
  "etaHEN 2.5B",
  "kstuff-lite v1.11",
  "ShadowMount 1.7b3",
  "elfldr v0.26",
  "pldmgr v0.5.2",
  "ftpsrv v0.21.1",
  "nanoDNS 0.4",
  "CheatRunner v0.17",
  "ps5debug 1.3.2",
  "websrv v0.34"
};
static const int payloadCount = 10;

void initDisplay() {
  pinMode(TFT_BL, OUTPUT);
  digitalWrite(TFT_BL, HIGH);
  
  tft.init();
  tft.setRotation(1);
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setTextSize(1);
  tft.setTextDatum(0);
}

void drawBootScreen() {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.setTextSize(2);
  tft.setCursor(10, 10);
  tft.println("PS5");
  tft.setCursor(10, 30);
  tft.println("AUTOLOADER");
  tft.setTextSize(1);
  tft.setTextColor(TFT_DARKGREEN, TFT_BLACK);
  tft.setCursor(10, 60);
  tft.println("v0.5.2");
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setCursor(10, 85);
  tft.println("Iniciando...");
}

void drawWifiScreen() {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_YELLOW, TFT_BLACK);
  tft.setTextSize(1);
  tft.setCursor(5, 5);
  tft.println("WiFi: ESP32_PORTAL");
  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.setCursor(5, 20);
  tft.print("AP IP: ");
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.println(WiFi.softAPIP().toString().c_str());
  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.setCursor(5, 35);
  tft.print("Conectados: ");
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.println(totalConnections);
  tft.setCursor(5, 55);
  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.println("PS5: Settings > Guide");
  tft.setCursor(5, 70);
  tft.println("  > User's Guide");
  tft.setCursor(5, 90);
  tft.setTextColor(TFT_DARKGREY, TFT_BLACK);
  tft.println("Botao: navegar payloads");
}

void drawPayloadList() {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_CYAN, TFT_BLACK);
  tft.setTextSize(1);
  tft.setCursor(5, 5);
  tft.println("== Payloads ==");
  
  int maxVisible = 8;
  int startIdx = 0;
  if (selectedPayload >= maxVisible) {
    startIdx = selectedPayload - maxVisible + 1;
  }
  
  for (int i = 0; i < maxVisible && (startIdx + i) < payloadCount; i++) {
    int idx = startIdx + i;
    tft.setCursor(5, 18 + i * 14);
    if (idx == selectedPayload) {
      tft.setTextColor(TFT_GREEN, TFT_BLACK);
      tft.print("> ");
    } else {
      tft.setTextColor(TFT_WHITE, TFT_BLACK);
      tft.print("  ");
    }
    tft.println(payloadNames[idx]);
  }
  
  // Scroll indicator
  if (payloadCount > maxVisible) {
    tft.setTextColor(TFT_DARKGREY, TFT_BLACK);
    tft.setCursor(120, 5);
    tft.print((selectedPayload + 1));
    tft.print("/");
    tft.println(payloadCount);
  }
  
  tft.setTextColor(TFT_DARKGREY, TFT_BLACK);
  tft.setCursor(5, 132);
  tft.println("2x: envia | segura: volta");
}

void drawExploitScreen(const char* status, int progress) {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_YELLOW, TFT_BLACK);
  tft.setTextSize(1);
  tft.setCursor(5, 10);
  tft.println("EXPLOIT RODANDO");
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setCursor(5, 30);
  tft.println(status);
  // Barra de progresso
  tft.drawRect(10, 55, 120, 10, TFT_WHITE);
  tft.fillRect(10, 55, (120 * progress) / 100, 10, TFT_GREEN);
}

void drawSuccessScreen() {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_GREEN, TFT_BLACK);
  tft.setTextSize(2);
  tft.setCursor(10, 30);
  tft.println("JAILBROKEN!");
  tft.setTextSize(1);
  tft.setTextColor(TFT_WHITE, TFT_BLACK);
  tft.setCursor(10, 60);
  tft.println("Atalho instalado em");
  tft.setCursor(10, 75);
  tft.println("Midia > WebKit");
  tft.setCursor(10, 95);
  tft.println("Autoloader");
  tft.setTextColor(TFT_DARKGREY, TFT_BLACK);
  tft.setCursor(10, 115);
  tft.println("ESP32 pode ser removido");
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
    case DISPLAY_EXPLOIT_RUNNING:
      drawExploitScreen("Aguardando PS5...", 50);
      break;
    case DISPLAY_SUCCESS:
      drawSuccessScreen();
      break;
  }
}

void handleButton() {
  bool btnState = digitalRead(BOTAO_PIN) == LOW;
  uint32_t now = millis();
  
  // Debounce
  if (btnState && !buttonPressed && (now - lastButtonPress) > 250) {
    buttonPressed = true;
    lastButtonPress = now;
    
    // Double-click detection (envia payload)
    if ((now - lastClickTime) < 500 && (now - lastClickTime) > 50) {
      // Enviar payload selecionado via HTTP ao PS5
      tft.fillScreen(TFT_GREEN);
      tft.setTextColor(TFT_WHITE, TFT_BLACK);
      tft.setCursor(20, 50);
      tft.setTextSize(1);
      tft.println("ENVIANDO");
      tft.setCursor(20, 70);
      tft.println(payloadNames[selectedPayload]);
      delay(1500);
      currentState = DISPLAY_WIFI;
      updateDisplay();
      lastClickTime = 0;
      return;
    }
    lastClickTime = now;
    
    // Navegacao entre telas
    if (currentState == DISPLAY_WIFI) {
      currentState = DISPLAY_PAYLOAD_LIST;
      selectedPayload = 0;
    } else if (currentState == DISPLAY_PAYLOAD_LIST) {
      selectedPayload = (selectedPayload + 1) % payloadCount;
    }
    updateDisplay();
  }
  
  // Botao secundario ou segurar = volta
  bool btn2State = digitalRead(BOTAO2_PIN) == LOW;
  if (btn2State && currentState == DISPLAY_PAYLOAD_LIST) {
    currentState = DISPLAY_WIFI;
    updateDisplay();
    delay(500);
  }
  
  if (!btnState) buttonPressed = false;
}

#endif // DISPLAY_ENABLE