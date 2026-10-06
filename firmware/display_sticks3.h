// display_sticks3.h - Prototipos das funcoes da tela ST7789
// Incluido por esp32-arduino.ino quando DISPLAY_ENABLE esta definido

#ifdef DISPLAY_ENABLE

#include <SPI.h>
#include <TFT_eSPI.h>

// Pinos do M5Stack StickS3 para ST7789
#define TFT_MOSI 2
#define TFT_SCK  3
#define TFT_CS   6
#define TFT_RS   5
#define TFT_RST  7
#define TFT_BL   9

// Botoes do StickS3
#define BOTAO_PIN   0  // Botao principal (GPIO0)
#define BOTAO2_PIN 14  // Botao secundario (GPIO14)

// Estados da UI
enum DisplayState {
  DISPLAY_BOOT,
  DISPLAY_WIFI,
  DISPLAY_PAYLOAD_LIST,
  DISPLAY_EXPLOIT_RUNNING,
  DISPLAY_SUCCESS,
  DISPLAY_ERROR
};

// Variaveis compartilhadas
extern int totalConnections;
extern volatile DisplayState currentState;
extern volatile int selectedPayload;

// Funcoes
void initDisplay();
void drawBootScreen();
void drawWifiScreen();
void drawPayloadList();
void updateDisplay();
void handleButton();

#endif // DISPLAY_ENABLE