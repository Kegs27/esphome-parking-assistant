# 🚗 ESPHome Parking Assistant

Smart parking assistant for garage with ultrasonic distance measurement and audio feedback.

![ESPHome](https://img.shields.io/badge/ESPHome-2025.9+-blue)
![ESP-IDF](https://img.shields.io/badge/ESP--IDF-5.5.1-green)
![License](https://img.shields.io/badge/license-MIT-orange)

## 📋 Table of Contents

- [Features](#-features)
- [Hardware](#-hardware)
- [Installation](#-installation)
- [Configuration](#️-configuration)
- [Usage](#-usage)
- [Development](#-development)
- [Troubleshooting](#-troubleshooting)

## ✨ Features

- ✅ **Configurable zones** - Set distance zones from Home Assistant
- ✅ **Audio feedback** - RTTTL buzzer with different beep patterns
- ✅ **Smart triggers** - Only active when garage door is open
- ✅ **Test mode** - Test without garage door sensor
- ✅ **OTA updates** - Wireless firmware updates via WiFi
- ✅ **Home Assistant integration** - Full integration with HA

## 🔧 Hardware

### Components

| Component | Model | Pin | Notes |
|-----------|-------|-----|-------|
| **Microcontroller** | ESP32 DevKit | - | ESP32-WROOM-32 |
| **Distance Sensor** | JSN-SR04T | GPIO32/33 | **Mode 1** (100kΩ on R19) |
| **Buzzer** | Passive buzzer | GPIO27 | RTTTL compatible |
| **Power** | 5V | VIN/GND | Via USB or external adapter |

### JSN-SR04T Sensor Setup (Mode 1)

**⚠️ IMPORTANT:** The JSN-SR04T must be in **Mode 1** for UART communication.

**Hardware modification:**
1. Solder a **100kΩ resistor** between the **R19 pad** on the PCB
2. This switches the sensor to **serial output mode**

**Advantages of Mode 1:**
- 🎯 Better accuracy
- 📡 UART communication (more reliable)
- 🔧 Less interference
- 📊 Range: 25cm - 4m

**Pin connection:**
```
JSN-SR04T (Mode 1)    →    ESP32
─────────────────────────────────
VCC (5V)              →    VIN/5V
GND                   →    GND
TX (Echo)             →    GPIO33 (RX)
RX (Trigger)          →    GPIO32 (TX)
```

### Wiring Diagram

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

## 🚀 Installation

### Requirements

- **Docker Desktop** - For ESPHome builds
- **Home Assistant** - For integration
- **WiFi network** - For ESP32 connectivity

### Step 1: Clone Repository

```bash
git clone https://github.com/quintencls/esphome-parking-assistant.git
cd esphome-parking-assistant
```

### Step 2: Configure Secrets

Copy and edit `secrets.yaml`:

```yaml
wifi_ssid: "YourWiFiName"
wifi_password: "YourWiFiPassword"
```

⚠️ **NEVER add `secrets.yaml` to git!**

### Step 3: First Build

```cmd
build.bat
```

**Build times:**
- 🐌 First time: ~8-10 minutes (downloads ESP-IDF tools)
- ⚡ Next time: ~1-3 minutes (uses cache)

### Step 4: Upload Firmware

**First time (via USB):**
```cmd
upload.bat
```

**Next time (via WiFi):**
```cmd
upload.bat
```

## ⚙️ Configuration

### Distance Zones

Configure zones in Home Assistant or adjust the YAML:

| Zone | Distance | Sound | Action |
|------|---------|-------|--------|
| **Zone 1** | > 1.20m | 🔇 No sound | Safe - drive on |
| **Zone 2** | 0.70m - 1.20m | 🔔 Slow beep | Watch out |
| **Zone 3** | 0.45m - 0.70m | 🔔🔔 Medium beep | Slow down! |
| **Zone 4** | 0.25m - 0.45m | 🔔🔔🔔 Fast beep | Careful! |
| **Zone 5** | < 0.25m | 🚨 Continuous alarm | **STOP!** |

### Home Assistant Entities

After adding to HA you get:

**Sensors:**
- `sensor.garage_distance` - Current distance in meters
- `sensor.parking_zone` - Current zone number
- `text_sensor.parking_zone_status` - Zone status text

**Switches:**
- `switch.parking_assistant_enabled` - Toggle system on/off
- `switch.test_mode` - Test without garage door sensor
- `switch.led_strip_enabled` - Toggle LED strip on/off

**Configuration:**
- `number.led_count` - Number of active LEDs (1-60)
- `number.zone_1_min` - Zone 1 threshold (no sound)
- `number.zone_2_min` - Zone 2 threshold (slow beep)
- `number.zone_3_min` - Zone 3 threshold (medium beep)
- `number.zone_4_min` - Zone 4 threshold (fast beep)
- `number.zone_1_beep_interval` - Beep interval zone 1
- `number.zone_2_beep_interval` - Beep interval zone 2
- `number.zone_3_beep_interval` - Beep interval zone 3
- `number.parking_complete_timeout` - Seconds stationary for parking complete

**Service:**
- `esphome.parking_assistant_garage_play_rtttl` - Test buzzer with custom RTTTL

## 🎮 Usage

### Daily Use

1. Open garage door
2. System activates automatically
3. Follow audio feedback while parking
4. System stops after closing garage door

### Test Mode

For testing without garage door:

1. Enable "Test Mode" via HA
2. System is now always active
3. Test different distances
4. Disable Test Mode after testing

### Custom RTTTL Tones

Test the buzzer with custom tones via HA Developer Tools:

```yaml
service: esphome.parking_assistant_garage_play_rtttl
data:
  song_str: "StarWars:d=4,o=5,b=180:8f,8f,8f,2a#,2f.6,8d#6,8d6,8c6,2a#.6,f.6,8d#6,8d6,8c6,2a#.6,f.6,8d#6,8d6,8d#6,2c6"
```

## 💻 Development

### Project Structure

```
esphome-parking-assistant/
├── 📄 esphome-parking-assistant.yaml   # Main configuration
├── 📄 secrets.yaml                     # WiFi credentials (not in git!)
├── 📄 README.md                        # This file
├── 📁 scripts/                         # Build & deployment scripts
│   ├── build.bat                       # Compile firmware
│   ├── upload.bat                      # Upload via WiFi
│   ├── logs.bat                        # View logs
│   ├── clean.bat                       # Clear build cache
│   ├── validate.bat                    # Validate YAML
│   ├── build-verbose.bat              # Build with verbose output
│   └── monitor.bat                     # Monitor build status
└── 📁 .esphome/                        # Build cache (not in git)
```

### Available Scripts

| Script | Function | Usage |
|--------|----------|-------|
| `build.bat` | Compile firmware | Double-click or `.\build.bat` |
| `upload.bat` | Upload to ESP32 | Double-click or `.\upload.bat` |
| `logs.bat` | View realtime logs | Double-click or `.\logs.bat` |
| `scripts\validate.bat` | Validate YAML | `.\scripts\validate.bat` |
| `scripts\clean.bat` | Clear build cache | `.\scripts\clean.bat` |

### Local Development

**Making changes:**
1. Edit `esphome-parking-assistant.yaml` locally
2. Save file
3. Run `build.bat` to compile
4. Run `upload.bat` to upload
5. Run `logs.bat` to view results

**No Home Assistant needed!** The YAML is local, HA sees the device via the API.

### Docker Cache

The project uses a persistent Docker volume (`esphome-cache`) for:
- ✅ Faster builds
- ✅ More reliable installation
- ✅ Fewer downloads

**Clear cache if problems occur:**
```cmd
scripts\clean.bat
```

## 🔍 Troubleshooting

### Sensor gives no readings

**Checklist:**
1. ✅ Is the 100kΩ resistor correctly soldered on R19?
2. ✅ Are TX and RX correctly connected (TX→GPIO33, RX→GPIO32)?
3. ✅ Is the sensor powered by 5V?
4. ✅ Check logs: `logs.bat`

### Build takes too long / hangs

**Solution:**
1. Wait patiently on first build (8-10 min is normal)
2. Check CPU usage: `docker stats`
3. If problems: run `scripts\clean.bat` and try again

### WiFi connection failed

1. Check `secrets.yaml` credentials
2. Ensure ESP32 is within WiFi range
3. Check logs for error messages
4. Reset ESP32 and try again

### Docker errors

**No Docker container running:**
```cmd
docker ps
```

**Docker cache problems:**
```cmd
scripts\clean.bat
```
Select "yes" to clear Docker volume.

## 📚 Documentation

- **[ESPHome Docs](https://esphome.io/)** - Official ESPHome documentation
- **[JSN-SR04T Datasheet](https://www.electrodragon.com/product/jsn-sr04t-waterproof-ultrasonic-ranging-module/)** - Sensor specifications

## 🤝 Contributing

Improvements are welcome! 

1. Fork the project
2. Create a feature branch (`git checkout -b feature/awesome-idea`)
3. Commit your changes (`git commit -m 'Add awesome idea'`)
4. Push to the branch (`git push origin feature/awesome-idea`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🙏 Credits

- **ESPHome** - Amazing framework for ESP devices
- **Home Assistant** - Best home automation platform
- **Community** - For all help and inspiration

---

**Made with ❤️ for a better parking experience**

