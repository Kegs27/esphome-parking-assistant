# 🚗 ESPHome Parking Assistant

Smart parkeer assistent voor in de garage met ultrasone afstandsmeting en audio feedback.

![ESPHome](https://img.shields.io/badge/ESPHome-2025.9+-blue)
![ESP-IDF](https://img.shields.io/badge/ESP--IDF-5.5.1-green)
![License](https://img.shields.io/badge/license-MIT-orange)

## 📋 Inhoudsopgave

- [Features](#-features)
- [Hardware](#-hardware)
- [Installatie](#-installatie)
- [Configuratie](#️-configuratie)
- [Gebruik](#-gebruik)
- [Development](#-development)
- [Troubleshooting](#-troubleshooting)
- [Documentatie](#-documentatie)

## ✨ Features

- ✅ **Configureerbare zones** - Stel afstandszones in vanuit Home Assistant
- ✅ **Audio feedback** - RTTTL buzzer met verschillende beep patronen
- ✅ **Smart triggers** - Alleen actief als garagepoort open is
- ✅ **Test mode** - Test zonder garagepoort sensor
- ✅ **OTA updates** - Draadloze firmware updates via WiFi
- ✅ **Home Assistant integratie** - Volledige integratie met HA

## 🔧 Hardware

### Componenten

| Component | Model | Pin | Opmerking |
|-----------|-------|-----|-----------|
| **Microcontroller** | ESP32 DevKit | - | ESP32-WROOM-32 |
| **Afstandssensor** | JSN-SR04T | GPIO32/33 | **Mode 1** (100kΩ op R19) |
| **Buzzer** | Passieve buzzer | GPIO27 | RTTTL compatible |
| **Voeding** | 5V | VIN/GND | Via USB of externe adapter |

### JSN-SR04T Sensor Setup (Mode 1)

**⚠️ BELANGRIJK:** De JSN-SR04T moet in **Mode 1** staan voor UART communicatie.

**Hardware modificatie:**
1. Soldeer een **100kΩ resistor** tussen de **R19 pad** op de printplaat
2. Dit schakelt de sensor om naar **serial output mode**

**Voordelen Mode 1:**
- 🎯 Betere nauwkeurigheid
- 📡 UART communicatie (betrouwbaarder)
- 🔧 Minder interference
- 📊 Bereik: 25cm - 4m

**Pin aansluiting:**
```
JSN-SR04T (Mode 1)    →    ESP32
─────────────────────────────────
VCC (5V)              →    VIN/5V
GND                   →    GND
TX (Echo)             →    GPIO33 (RX)
RX (Trigger)          →    GPIO32 (TX)
```

### Bedrading Schema

```
ESP32                 JSN-SR04T
┌─────────┐          ┌──────────┐
│         │          │          │
│ GPIO32──┼─────────→│ RX       │
│ GPIO33──┼←─────────┼─ TX      │
│ GPIO27──┼───→ 🔊   │          │
│         │  Buzzer  │ VCC ←─5V │
│ GND ────┼──────────┼─ GND     │
└─────────┘          └──────────┘
```

## 🚀 Installatie

### Vereisten

- **Docker Desktop** - Voor ESPHome builds
- **Home Assistant** - Voor integratie
- **WiFi netwerk** - Voor ESP32 connectiviteit

### Stap 1: Repository Klonen

```bash
git clone https://github.com/jouw-username/esphome-parking-assistant.git
cd esphome-parking-assistant
```

### Stap 2: Secrets Configureren

Kopieer en bewerk `secrets.yaml`:

```yaml
wifi_ssid: "JouwWiFiNaam"
wifi_password: "JouwWiFiWachtwoord"
```

⚠️ **Voeg `secrets.yaml` NOOIT toe aan git!**

### Stap 3: Eerste Build

```cmd
build.bat
```

**Build tijden:**
- 🐌 Eerste keer: ~8-10 minuten (downloadt ESP-IDF tools)
- ⚡ Volgende keer: ~1-3 minuten (gebruikt cache)

### Stap 4: Firmware Uploaden

**Eerste keer (via USB):**
```cmd
upload.bat
```

**Volgende keer (via WiFi):**
```cmd
upload.bat
```

## ⚙️ Configuratie

### Afstandszones

Configureer zones in Home Assistant of pas de YAML aan:

| Zone | Afstand | Geluid | Actie |
|------|---------|--------|-------|
| **Zone 1** | > 1.20m | 🔇 Geen geluid | Veilig - rijd door |
| **Zone 2** | 0.70m - 1.20m | 🔔 Langzaam beep | Let op |
| **Zone 3** | 0.45m - 0.70m | 🔔🔔 Medium beep | Vertraag! |
| **Zone 4** | 0.25m - 0.45m | 🔔🔔🔔 Snel beep | Voorzichtig! |
| **Zone 5** | < 0.25m | 🚨 Continue alarm | **STOP!** |

### Home Assistant Entities

Na toevoegen aan HA krijg je:

**Sensors:**
- `sensor.garage_afstand` - Huidige afstand in meters
- `sensor.parking_zone` - Huidige zone nummer
- `text_sensor.parking_zone_status` - Zone status tekst

**Switches:**
- `switch.parking_assistant_enabled` - Schakel systeem aan/uit
- `switch.test_mode` - Test zonder garagepoort sensor

**Configuratie:**
- `number.zone_1_min` - Zone 1 drempel
- `number.zone_2_min` - Zone 2 drempel
- `number.zone_3_min` - Zone 3 drempel
- `number.zone_4_min` - Zone 4 drempel

**Service:**
- `esphome.parking_assistant_garage_play_rtttl` - Test buzzer met custom RTTTL

## 🎮 Gebruik

### Dagelijks Gebruik

1. Open garagepoort
2. Systeem activeert automatisch
3. Volg audio feedback tijdens parkeren
4. Systeem stopt na sluiten garagepoort

### Test Mode

Voor testen zonder garagepoort:

1. Schakel "Test Mode" in via HA
2. Systeem is nu altijd actief
3. Test verschillende afstanden
4. Schakel Test Mode uit na test

### Custom RTTTL Tonen

Test de buzzer met custom tonen via HA Developer Tools:

```yaml
service: esphome.parking_assistant_garage_play_rtttl
data:
  song_str: "StarWars:d=4,o=5,b=180:8f,8f,8f,2a#,2f.6,8d#6,8d6,8c6,2a#.6,f.6,8d#6,8d6,8c6,2a#.6,f.6,8d#6,8d6,8d#6,2c6"
```

## 💻 Development

### Project Structuur

```
esphome-parking-assistant/
├── 📄 esphome-parking-assistant.yaml   # Hoofdconfiguratie
├── 📄 secrets.yaml                     # WiFi credentials (niet in git!)
├── 📄 README.md                        # Deze file
├── 📁 scripts/                         # Build & deployment scripts
│   ├── build.bat                       # Compileer firmware
│   ├── upload.bat                      # Upload via WiFi
│   ├── logs.bat                        # Bekijk logs
│   ├── clean.bat                       # Wis build cache
│   ├── validate.bat                    # Valideer YAML
│   ├── build-verbose.bat              # Build met verbose output
│   └── monitor.bat                     # Monitor build status
├── 📁 docs/                            # Documentatie
│   ├── STATUS.md                       # Build status info
│   └── LOKAAL-vs-HA.md                # Lokaal vs HA builds
└── 📁 .esphome/                        # Build cache (niet in git)
```

### Beschikbare Scripts

| Script | Functie | Gebruik |
|--------|---------|---------|
| `build.bat` | Compileer firmware | Dubbel-klik of `.\build.bat` |
| `upload.bat` | Upload naar ESP32 | Dubbel-klik of `.\upload.bat` |
| `logs.bat` | Bekijk realtime logs | Dubbel-klik of `.\logs.bat` |
| `scripts\validate.bat` | Valideer YAML | `.\scripts\validate.bat` |
| `scripts\clean.bat` | Wis build cache | `.\scripts\clean.bat` |

### Lokaal Ontwikkelen

**Wijzigingen maken:**
1. Bewerk `esphome-parking-assistant.yaml` lokaal
2. Save bestand
3. Run `build.bat` om te compileren
4. Run `upload.bat` om te uploaden
5. Run `logs.bat` om resultaat te zien

**Geen Home Assistant nodig!** De YAML staat lokaal, HA ziet het device via de API.

### Docker Cache

Het project gebruikt een persistent Docker volume (`esphome-cache`) voor:
- ✅ Snellere builds
- ✅ Betrouwbaardere installatie
- ✅ Minder downloads

**Cache wissen bij problemen:**
```cmd
scripts\clean.bat
```

## 🔍 Troubleshooting

### Sensor geeft geen metingen

**Checklist:**
1. ✅ Is de 100kΩ resistor correct gesoldeerd op R19?
2. ✅ Staan TX en RX correct verbonden (TX→GPIO33, RX→GPIO32)?
3. ✅ Staat de sensor op 5V voeding?
4. ✅ Check logs: `logs.bat`

### Build duurt te lang / hangt

**Oplossing:**
1. Wacht geduldig bij eerste build (8-10 min normaal)
2. Check CPU gebruik: `docker stats`
3. Bij problemen: run `scripts\clean.bat` en probeer opnieuw

### WiFi verbinding mislukt

1. Check `secrets.yaml` credentials
2. Zorg dat ESP32 binnen WiFi bereik is
3. Check logs voor error messages
4. Reset ESP32 en probeer opnieuw

### Docker errors

**Geen Docker container draait:**
```cmd
docker ps
```

**Docker cache problemen:**
```cmd
scripts\clean.bat
```
Selecteer "ja" om Docker volume te wissen.

## 📚 Documentatie

- **[Build Status](docs/STATUS.md)** - Huidige build informatie
- **[Lokaal vs HA](docs/LOKAAL-vs-HA.md)** - Vergelijking build methodes
- **[ESPHome Docs](https://esphome.io/)** - Officiële ESPHome documentatie
- **[JSN-SR04T Datasheet](https://www.electrodragon.com/product/jsn-sr04t-waterproof-ultrasonic-ranging-module/)** - Sensor specificaties

## 🤝 Contributing

Verbeteringen zijn welkom! 

1. Fork het project
2. Maak een feature branch (`git checkout -b feature/geweldig-idee`)
3. Commit je wijzigingen (`git commit -m 'Voeg geweldig idee toe'`)
4. Push naar de branch (`git push origin feature/geweldig-idee`)
5. Open een Pull Request

## 📝 License

Dit project is gelicenseerd onder de MIT License.

## 🙏 Credits

- **ESPHome** - Geweldig framework voor ESP devices
- **Home Assistant** - Beste home automation platform
- **Community** - Voor alle hulp en inspiratie

---

**Gemaakt met ❤️ voor een betere parkeerervaring**

