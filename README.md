# Garage Parking Assistant

A wall-mounted parking assistant for your garage that helps you center your vehicle and stop at the perfect distance. Uses a Time-of-Flight (ToF) distance sensor, audible beep patterns, visual indicators (laser + LEDs), and optional Home Assistant integration.

**Key Features:**
- 🚗 **No car-mounted hardware** - Everything mounts on the garage wall
- 🔌 **Standalone operation** - Works without Wi-Fi or Home Assistant
- 📏 **Accurate distance measurement** - ToF sensor with ~5 inch accuracy target
- 🎵 **Progressive audio warnings** - Beeps get faster as you approach, then STOP signal
- 🚨 **BACK UP alert** - Warns if you overshoot the target
- 🏠 **Home Assistant integration** - Dashboard, configuration, and automation triggers
- 🔧 **Easy calibration** - Adjust zones and thresholds without reflashing

---

## Project Status: Phase 1 (Sensor Validation)

This project is under active development. Currently in **Phase 1**: validating the VL53L0X sensor accuracy against our calibration vehicle (Mazda CX-5).

See [`PLAN.md`](PLAN.md) for complete project roadmap and success criteria.

### Completed
- [x] Project documentation and hardware plan
- [x] ESPHome configuration for Arduino Nano ESP32 + VL53L0X sensor
- [x] Distance measurement with stability metrics (min/max/std-dev)
- [x] Lost-reading detection and timeout handling
- [x] Basic buzzer control circuit

### In Progress
- [ ] Physical sensor validation against CX-5 bumper
- [ ] Long-range mode testing (target: ≥1.2m reliable range)
- [ ] Stability testing (stationary vehicle, ±5 cm accuracy target)

### Planned (Future Phases)
- Phase 2: Parking state machine with zones and hysteresis
- Phase 3: Buzzer patterns, green laser, and LED indicators
- Phase 4: Full Home Assistant integration
- Phase 5: Mechanical mounting and enclosure
- Phase 6: Custom PCB design

---

## Hardware

### Current Components (Phase 1)

| Component | Part Number | Purpose |
|-----------|-------------|---------|
| **Microcontroller** | Arduino Nano ESP32 (ABX00083) | ESP32-S3 main controller |
| **Distance Sensor** | MusRock TOF200C (VL53L0X) | Time-of-Flight I2C sensor |
| **Buzzer** | DIYables 5V Active Piezo | Audio feedback |
| **Terminal Base** | 52Pi EP-0262 | Breadboard alternative for prototyping |
| **Level Converter** | SparkFun BOB-12009 | (Likely not needed - both devices are 3.3V) |

### Future Components (Phase 3+)

- Green line laser (532nm, 5V) for centering guidance
- Status LEDs (WS2812B strip or discrete RGB)
- MOSFET drivers for laser and LEDs
- 3D-printed enclosure and mounting hardware
- Custom PCB (Phase 6)

**Detailed specifications:** See [`HARDWARE.md`](HARDWARE.md)

---

## Getting Started (Phase 1)

### Prerequisites

- **ESPHome**: Version 2024.11.0 or newer
  - Install: `pip install esphome` or use Docker
- **Home Assistant** (optional): For dashboard and configuration UI
- **USB-C cable**: For initial programming
- **Hardware assembled**: VL53L0X sensor and buzzer wired per [`HARDWARE.md`](HARDWARE.md)

### 1. Configure Secrets

Create `esphome/secrets.yaml` from the template:

```bash
cp esphome/secrets.yaml.example esphome/secrets.yaml
```

Edit `esphome/secrets.yaml` and fill in your credentials:

```yaml
wifi_ssid: "YourWiFiSSID"
wifi_password: "YourWiFiPassword"
api_encryption_key: "your-32-char-base64-key-here=="
ota_password: "your-ota-password"
fallback_password: "fallback-ap-password"
```

**Generate API key:**
```bash
openssl rand -base64 32
```

> **Important:** Never commit `secrets.yaml` to git! It's already in `.gitignore`.

### 2. Validate Configuration

Check that your ESPHome configuration is valid:

```bash
esphome config esphome/garage-parking-assistant.yaml
```

You should see:
```
INFO Configuration is valid!
```

### 3. First Flash (USB)

Connect the Arduino Nano ESP32 via USB-C and flash:

```bash
esphome run esphome/garage-parking-assistant.yaml
```

Or use the ESPHome dashboard:
1. Start dashboard: `esphome dashboard esphome/`
2. Open browser: `http://localhost:6052`
3. Click "Upload" on the `garage-parking-assistant` card
4. Select "Plug into this computer"

### 4. Access Web Interface

After flashing, the device creates a web server at:

```
http://garage-parking-assistant.local
```

You can view:
- Real-time distance readings (meters, cm, inches)
- Stability metrics (min, max, standard deviation)
- Sensor status and diagnostics
- Wi-Fi signal strength
- Toggle buzzer for testing

> **Note:** If `.local` doesn't work, check the IP address in ESPHome logs and access via `http://<IP_ADDRESS>`.

### 5. View Logs

Monitor real-time logs:

```bash
esphome logs esphome/garage-parking-assistant.yaml
```

Look for:
- `Found i2c device at address 0x29` (VL53L0X detected)
- `Distance: 0.XXX m (XX.X cm, XX.X in)` (readings are coming through)
- `Sensor Status: OK: Valid reading` (sensor is healthy)

### 6. Test Distance Readings

1. **Place vehicle** at known distances:
   - 25 cm (minimum range)
   - 50 cm, 75 cm, 100 cm
   - 120 cm (target STOP distance)
   - 150 cm, 200 cm (long-range limit test)

2. **Observe readings** in web UI or logs
   - Check stability: Is standard deviation <3 cm when stationary?
   - Check accuracy: Do readings match measured distances within ±5 cm?
   - Check range: What's the maximum reliable range on your vehicle's bumper?

3. **Test lost-reading detection**
   - Block the sensor with your hand
   - Should see "Error: Lost reading (timeout)" within 2 seconds

4. **Test buzzer**
   - Toggle "Buzzer Test" switch in web UI or Home Assistant
   - Should hear a 2 kHz tone when ON

### 7. Over-The-Air Updates (After First Flash)

Once Wi-Fi is configured, you can update wirelessly:

```bash
esphome run esphome/garage-parking-assistant.yaml --device garage-parking-assistant.local
```

Or via ESPHome dashboard (auto-detects OTA-capable devices).

---

## Home Assistant Integration (Optional)

### Add Device

1. **Automatic discovery**: HA should auto-detect the device. Click "Configure" in notifications.
2. **Manual add**: 
   - Go to Settings → Devices & Services → Add Integration
   - Search for "ESPHome"
   - Enter hostname: `garage-parking-assistant.local` or IP address
   - Enter API encryption key from `secrets.yaml`

### Available Entities (Phase 1)

**Sensors:**
- `sensor.garage_parking_assistant_distance` - Distance in meters
- `sensor.garage_parking_assistant_distance_cm` - Distance in centimeters
- `sensor.garage_parking_assistant_distance_inches` - Distance in inches
- `sensor.garage_parking_assistant_distance_min_5s` - Minimum distance (5s window)
- `sensor.garage_parking_assistant_distance_max_5s` - Maximum distance (5s window)
- `sensor.garage_parking_assistant_distance_std_dev_5s` - Standard deviation (stability)
- `sensor.garage_parking_assistant_wifi_signal` - Wi-Fi RSSI

**Switches:**
- `switch.garage_parking_assistant_buzzer_test` - Manual buzzer on/off

**Diagnostics:**
- `text_sensor.garage_parking_assistant_sensor_status` - Sensor health status
- `sensor.garage_parking_assistant_uptime` - Device uptime
- `binary_sensor.garage_parking_assistant_status` - Online/offline

Future phases will add zone configuration, state machine status, and automation triggers.

---

## Phase 1 Success Criteria

See [`PLAN.md`](PLAN.md) for detailed criteria. Key validation points:

- [ ] ESPHome config compiles without errors ✅
- [ ] Sensor detects vehicle from 25 cm to minimum 1.2 m
- [ ] Long-range mode tested: maximum reliable range documented
- [ ] Distance stable within ±5 cm when vehicle stationary
- [ ] Update rate ≥4 Hz (check log timestamps)
- [ ] Standard deviation <3 cm for stationary vehicle
- [ ] Lost-reading detection triggers within 2 seconds
- [ ] Buzzer test switch activates buzzer correctly

---

## Troubleshooting

### Sensor Not Detected

**Symptoms:** Logs show `ERROR: Failed to communicate with VL53L0X`

**Fixes:**
1. Check I2C wiring: SDA to A4, SCL to A5 (not swapped)
2. Verify 3.3V power at sensor VCC pin (use multimeter)
3. Ensure common ground connection between ESP32 and sensor
4. Try slower I2C: Change `frequency: 400kHz` to `frequency: 100kHz`
5. Check for loose connections or damaged wires

### Readings Are Unstable

**Symptoms:** Distance jumps around, std-dev >5 cm

**Fixes:**
1. Ensure sensor is mounted rigidly (no vibration)
2. Check for IR interference (sunlight, other IR sources)
3. Increase filter window sizes in YAML (median, moving average)
4. Test with garage door closed (eliminate sunlight)
5. Verify sensor lens is clean (no dust or obstructions)

### No Buzzer Sound

**Symptoms:** Buzzer test switch does nothing

**Fixes:**
1. Check transistor wiring: D9 → 10kΩ resistor → base (NPN)
2. Verify 5V supply at buzzer VCC
3. Test GPIO: Replace buzzer with LED to verify D9 output works
4. Check transistor orientation: Emitter to GND for NPN
5. Ensure buzzer module is "active" type (has internal oscillator)

### Wi-Fi Won't Connect

**Symptoms:** Device stuck in "Connecting to WiFi..."

**Fixes:**
1. Verify `secrets.yaml` has correct SSID and password
2. Check router supports 2.4 GHz (ESP32 does not support 5 GHz)
3. Ensure ESP32 is within Wi-Fi range
4. Try fallback hotspot: Connect to "garage-parking-assistant Fallback"
5. Check router firewall/MAC filtering settings

### `.local` Domain Doesn't Resolve

**Symptoms:** Cannot access `http://garage-parking-assistant.local`

**Fixes:**
1. Find IP address in ESPHome logs (look for "WiFi connected" message)
2. Access via IP: `http://<IP_ADDRESS>`
3. Install mDNS/Bonjour service (Windows: Bonjour Print Services, Linux: avahi-daemon)
4. Add device to Home Assistant (HA handles mDNS resolution)

### More Help

- Check logs with `esphome logs esphome/garage-parking-assistant.yaml`
- See [`HARDWARE.md`](HARDWARE.md) for wiring diagrams and component specs
- See [`.cursor/rules`](.cursor/rules) for debugging checklist
- ESPHome documentation: https://esphome.io/

---

## Project Structure

```
garage-parking-assistant/
├── README.md                           # This file
├── PLAN.md                             # Project plan, phases, requirements
├── HARDWARE.md                         # Hardware specs, wiring, BOM
├── LICENSE                             # MIT License (original + this fork)
├── .gitignore                          # Git ignore rules
├── .cursor/
│   └── rules                           # AI agent guidelines
├── esphome/
│   ├── garage-parking-assistant.yaml   # Main ESPHome configuration
│   └── secrets.yaml.example            # Secrets template
├── upstream/                           # Original project files (reference)
│   ├── esphome-parking-assistant.yaml  # Original config
│   └── README-original.md              # Original README
└── scripts/                            # Original build scripts (Windows)
    ├── build.bat
    ├── upload.bat
    └── logs.bat
```

---

## Development

### For AI Agents

If you are an AI coding assistant working on this project:

1. **Read first**: `.cursor/rules`, `PLAN.md`, `HARDWARE.md`
2. **Work one phase at a time**: Do not implement future phase features
3. **Parking logic on-device**: Never make parking decisions dependent on Wi-Fi or HA
4. **Document changes**: Update `PLAN.md` or `HARDWARE.md` when adding features/hardware
5. **Test before commit**: Run `esphome config` validation at minimum

### For Humans

1. **Validate config**: `esphome config esphome/garage-parking-assistant.yaml`
2. **Compile**: `esphome compile esphome/garage-parking-assistant.yaml`
3. **Upload USB**: `esphome upload esphome/garage-parking-assistant.yaml`
4. **Upload OTA**: `esphome upload esphome/garage-parking-assistant.yaml --device <hostname>`
5. **View logs**: `esphome logs esphome/garage-parking-assistant.yaml`
6. **Clean build**: `esphome clean esphome/garage-parking-assistant.yaml`

---

## Contributing

This is a personal project, but suggestions and improvements are welcome!

1. Open an issue to discuss proposed changes
2. Fork the repository
3. Create a feature branch (`git checkout -b feature/amazing-feature`)
4. Test your changes thoroughly (hardware and software)
5. Update documentation (`PLAN.md`, `HARDWARE.md`, README)
6. Commit with conventional format (`feat(phase2): add zone hysteresis`)
7. Open a pull request with test results and photos/videos

---

## Credits and License

### Original Project

This project is a fork of **[quintencls/esphome-parking-assistant](https://github.com/quintencls/esphome-parking-assistant)** by Quinten Claes, licensed under the MIT License.

The original project used an ESP32 DevKit with a JSN-SR04T ultrasonic sensor in UART mode, WS2812B LED strip, and passive buzzer. We adapted it to use:
- Arduino Nano ESP32 (ESP32-S3)
- VL53L0X Time-of-Flight I2C sensor
- Active 5V buzzer module
- Different sensor mounting approach (wall-mounted, no car hardware)

Original project files are preserved in the [`upstream/`](upstream/) directory for reference.

### This Fork

Adapted and extended by [Your Name/Organization] for a Mazda CX-5 in a residential garage.

**License:** MIT (see [`LICENSE`](LICENSE))

**Key changes from original:**
- Switched from ultrasonic (JSN-SR04T) to Time-of-Flight (VL53L0X) sensor
- Changed hardware platform to Arduino Nano ESP32
- Added comprehensive project planning (phased approach)
- Added detailed hardware documentation with safety notes
- Restructured configuration for standalone operation (parking logic on ESP32)
- Added stability metrics (min/max/std-dev) for sensor validation
- Planned future enhancements: green laser centering, BACK UP warning, custom PCB

### Acknowledgments

- **Quinten Claes** - Original esphome-parking-assistant project
- **ESPHome Project** - Amazing framework for ESP32 devices
- **Home Assistant** - Best open-source home automation platform

---

## Safety Notice

⚠️ **Important Safety Reminders:**

- This is a **parking aid**, not a collision avoidance system
- Always use mirrors and direct observation when parking
- Sensor failures can occur - do not rely on it exclusively
- If installing permanent power, consult a licensed electrician
- Laser modules (Phase 3+) should be Class 2 (<1 mW) for safety
- Keep sensor lens clean and unobstructed for accurate readings

---

## Support

- **Issues**: Open a GitHub issue for bugs or questions
- **Documentation**: Check `PLAN.md`, `HARDWARE.md`, or `.cursor/rules`
- **ESPHome help**: https://esphome.io/
- **Home Assistant help**: https://community.home-assistant.io/

---

**Made with ❤️ for a better parking experience**

