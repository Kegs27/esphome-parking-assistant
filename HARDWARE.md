# Hardware Configuration

## Bill of Materials (BOM)

### Current Hardware (Phase 1)

| Component | Part Number | Quantity | Purpose | Status |
|-----------|-------------|----------|---------|--------|
| **Microcontroller** | Arduino Nano ESP32 (ABX00083) | 1 | Main controller (ESP32-S3) | ✅ Purchased |
| **Terminal Base** | 52Pi EP-0262 | 1 | Breadboard alternative for prototyping | ✅ Purchased |
| **Distance Sensor** | MusRock TOF200C (VL53L0X) | 1 | Time-of-Flight I2C distance sensor | ✅ Purchased |
| **Buzzer** | DIYables 5V Active Piezo Buzzer Module | 1 | Audio feedback | ✅ Purchased |
| **Level Converter** | SparkFun BOB-12009 | 1 | Bidirectional I2C level shifter | ✅ Purchased (likely not needed) |

### Future Hardware (Phase 2+)

| Component | Specification | Quantity | Purpose | Status |
|-----------|---------------|----------|---------|--------|
| **Green Line Laser** | 532nm, 5V, line lens, 5-50mW | 1 | Centering guide | 🔵 Planned |
| **Status LEDs** | WS2812B strip or discrete red/yellow/green | 3-10 | Zone indication | 🔵 Planned |
| **MOSFET Drivers** | Logic-level N-channel (2N7000, BS170, or IRLZ44N) | 2-3 | Laser and LED control | 🔵 Planned |
| **Power Supply** | 5V 2A wall adapter or hardwired | 1 | Permanent power | 🔵 Planned |
| **Custom PCB** | KiCad design, 2-layer PCB | 1 | Replace breadboard | 🔵 Phase 6 |
| **Enclosure** | 3D-printed ABS/PETG | 1 | Weather protection | 🔵 Phase 5 |
| **Mounting Hardware** | Brackets, screws, adjustable arms | 1 set | Wall mounting | 🔵 Phase 5 |

---

## Pin Assignments (Arduino Nano ESP32)

### Phase 1: Sensor + Buzzer Only

| Function | GPIO Pin | Physical Pin | Notes | Status |
|----------|----------|--------------|-------|--------|
| **I2C SDA** | GPIO11 | A4 | VL53L0X data line (A4 = GPIO11) | ✅ Active |
| **I2C SCL** | GPIO12 | A5 | VL53L0X clock line (A5 = GPIO12) | ✅ Active |
| **Buzzer Control** | GPIO5 | D9 | PWM output to buzzer driver (via transistor, D9 = GPIO5) | ✅ Active |
| **3.3V Power** | 3V3 | 3V3 pin | Power for VL53L0X sensor | ✅ Active |
| **Ground** | GND | GND pin | Common ground | ✅ Active |
| **USB Power** | VUSB | USB connector | 5V power input (development) | ✅ Active |

### Phase 2+: Additional I/O

| Function | GPIO Pin | Physical Pin | Notes | Status |
|----------|----------|--------------|-------|--------|
| **Green Laser** | GPIO6 | D10 | Digital out to MOSFET gate (5V laser, D10 = GPIO6) | 🔵 Reserved |
| **Status LED Red** | GPIO7 | D11 | Digital out (discrete LED or WS2812B data, D11 = GPIO7) | 🔵 Reserved |
| **Status LED Yellow** | GPIO8 | D12 | Digital out (discrete LED, D12 = GPIO8) | 🔵 Reserved |
| **Status LED Green** | GPIO9 | D13 | Digital out (discrete LED or built-in, D13 = GPIO9) | 🔵 Reserved |
| **Spare GPIO 1** | GPIO10 | D2 | Future expansion (e.g., backup sensor, button, D2 = GPIO10) | 🔵 Reserved |
| **Spare GPIO 2** | GPIO3 | D3 | Future expansion (D3 = GPIO3) | 🔵 Reserved |

### Notes on Pin Selection

1. **I2C Pins (A4/A5)**: Hardware I2C0 interface on ESP32-S3. Fast and reliable. These are the standard I2C pins for Arduino compatibility.

2. **Buzzer on D9**: Supports PWM (LEDC peripheral) for tone generation. Any GPIO with PWM capability works, but D9 is easily accessible on the Nano ESP32.

3. **Laser on D10**: Digital output for MOSFET gate. Does not need PWM (laser is on/off only).

4. **LED Pins (D11-D13)**: 
   - **Option A (discrete LEDs)**: 3 separate digital outputs
   - **Option B (WS2812B strip)**: Use only D11 for data line, D12/D13 unused
   - D13 has a built-in LED on many Arduino boards, useful for quick testing

5. **5V vs 3.3V**:
   - VL53L0X: **3.3V only** (connect to 3V3 pin)
   - Buzzer module: **5V** (connect to VUSB or external 5V supply)
   - Laser: **5V** (connect via MOSFET to VUSB or external supply)
   - MOSFETs: Gate driven by **3.3V GPIO** (use logic-level MOSFETs)

---

## Wiring Diagrams

### Phase 1: VL53L0X Sensor + Buzzer

```
┌────────────────────────────────────────────────────────────────────────┐
│                     Arduino Nano ESP32                                 │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                                                              │   │
│  │   3V3 ───────────────────────┐                              │   │
│  │   GND ─────────────────┐     │                              │   │
│  │   A4 (SDA) ───────┐    │     │                              │   │
│  │   A5 (SCL) ─────┐ │    │     │                              │   │
│  │   D9 ──────┐    │ │    │     │                              │   │
│  │   VUSB ──┐ │    │ │    │     │                              │   │
│  │          │ │    │ │    │     │                              │   │
│  └──────────┼─┼────┼─┼────┼─────┼──────────────────────────────┘   │
│             │ │    │ │    │     │                                    │
└─────────────┼─┼────┼─┼────┼─────┼────────────────────────────────────┘
              │ │    │ │    │     │
              │ │    │ │    │     └─────────┐
              │ │    │ │    └───────────┐   │
              │ │    │ │                │   │
              │ │    │ └──────────┐     │   │
              │ │    └──────┐     │     │   │
              │ │           │     │     │   │
┌─────────────┼─┼───────────┼─────┼─────┼───┼────────────────────┐
│  VL53L0X    │ │           │     │     │   │                    │
│  ToF Sensor │ │           │     │     │   │                    │
│             │ │           │     │     │   │                    │
│     VCC ────┼─┼───────────┼─────┼─────┼───┘ (3.3V)            │
│     GND ────┼─┼───────────┼─────┼─────┘                        │
│     SDA ────┼─┼───────────┼─────┘                              │
│     SCL ────┼─┼───────────┘                                    │
│             │ │                                                │
└─────────────┼─┼────────────────────────────────────────────────┘
              │ │
              │ │
┌─────────────┼─┼────────────────────────────────────────────────┐
│  Buzzer     │ │                                                │
│  Driver     │ │                                                │
│  Circuit    │ │                                                │
│             │ │                                                │
│  ┌──────────┼─┘                                                │
│  │ 5V ──────┘                                                  │
│  │                                                             │
│  │     ┌────┐  10kΩ                                           │
│  │  D9 ─┤ R1 ├───┬───────┐                                    │
│  │     └────┘   │       │                                     │
│  │              │      ┌─┴─┐  NPN Transistor (e.g., 2N3904)  │
│  │              │      │ B │                                  │
│  │              │      └─┬─┘                                  │
│  │              │        │                                     │
│  │              │     ┌──┴──┐ C                               │
│  │              │     │     │                                  │
│  │        5V ───┼─────┤ Buz │  Active Buzzer Module           │
│  │              │     │zer │                                  │
│  │              │     └──┬──┘                                 │
│  │              │        │ E                                   │
│  │              │      ┌─┴─┐                                  │
│  │              │      │ T │                                  │
│  │              │      └─┬─┘                                  │
│  │              │        │                                     │
│  │        GND ──┴────────┴─────────────────────────────────── │
│  │                                                             │
│  │  Components:                                               │
│  │  - R1: 10kΩ base resistor                                 │
│  │  - T: 2N3904 NPN transistor (or 2N2222)                   │
│  │  - Buzzer: 5V active piezo module                         │
│  │                                                             │
│  │  Alternative: Replace NPN with logic-level N-MOSFET       │
│  │  (2N7000, BS170) - gate to D9, drain to buzzer+,          │
│  │  source to GND, buzzer- to 5V. Add 10kΩ pulldown          │
│  │  gate-to-source.                                           │
│  │                                                             │
└─────────────────────────────────────────────────────────────────┘

Notes:
- VL53L0X powered from 3.3V (NOT 5V)
- Buzzer powered from 5V (VUSB during development, external supply later)
- D9 output is 3.3V logic, safe for transistor base (with current-limiting resistor)
- Transistor acts as switch: D9 HIGH → buzzer ON, D9 LOW → buzzer OFF
```

### Phase 2+: Full System with Laser and LEDs

```
┌────────────────────────────────────────────────────────────────────────┐
│                     Arduino Nano ESP32                                 │
│  Inputs:  A4 (SDA), A5 (SCL)                                           │
│  Outputs: D9 (Buzzer), D10 (Laser), D11-D13 (LEDs or WS2812B data)    │
│  Power:   3V3 (sensor), VUSB or VIN (5V for peripherals)              │
└────────────────────────────────────────────────────────────────────────┘
              │
              ├── [VL53L0X Sensor] (I2C on A4/A5, powered by 3V3)
              │
              ├── [Buzzer Driver] (D9 → NPN/MOSFET → 5V Buzzer)
              │
              ├── [Laser Driver] (D10 → N-MOSFET → 5V Green Laser Module)
              │      - MOSFET: IRLZ44N or similar logic-level
              │      - Gate: D10 (3.3V GPIO)
              │      - Drain: Laser positive
              │      - Source: GND
              │      - Laser negative: 5V supply
              │      - Gate resistor: 10kΩ pulldown (gate to GND)
              │
              └── [Status LEDs] - Two Options:
                    Option A: Discrete LEDs on D11, D12, D13
                      - Each LED: GPIO → 330Ω resistor → LED → GND
                    Option B: WS2812B Addressable LED Strip
                      - D11 → DIN of first LED
                      - 5V supply to LED VCC
                      - GND to LED GND
                      - 330Ω resistor in series with DIN recommended
                      - 100-1000µF capacitor on 5V supply rail

Future: External 5V 2A power supply replaces VUSB for permanent installation.
```

---

## Component Specifications

### VL53L0X Time-of-Flight Sensor (MusRock TOF200C)

- **Interface**: I2C (address 0x29, not changeable without XSHUT pin manipulation)
- **Operating voltage**: 2.6V - 3.5V (use 3.3V)
- **I2C logic level**: 3.3V (5V tolerant on some modules, but check datasheet)
- **Current draw**: ~10 mA typical, ~19 mA peak
- **Range**:
  - Default mode: 25 cm to ~1.2 m (reliable on most surfaces)
  - Long-range mode: 25 cm to ~2 m (best case, reflective targets only)
- **Accuracy**: ±3% typical (±3-5 cm at 1 m)
- **Field of view**: 25° cone
- **Update rate**: Up to 50 Hz (20 ms per reading)
- **Mounting**: Ensure clear line of sight; avoid IR-reflective obstructions

**Critical Notes**:
- Long-range mode performance varies greatly with target reflectivity
- Dark or curved bumpers (like the Mazda CX-5) may limit effective range
- Module should have onboard 3.3V regulator if it accepts 5V - **verify before connecting**

### DIYables 5V Active Piezo Buzzer Module

- **Operating voltage**: 5V (3.3V may produce weak sound)
- **Current draw**: ~30 mA typical
- **Control**: Simple on/off (high = sound, low = silent)
- **Tone**: Fixed frequency (~2-4 kHz, module-dependent)
- **Volume**: ~85 dB @ 10 cm (loud enough for garage environment)
- **Connection**: Signal, VCC (5V), GND
- **Driver required**: Cannot be driven directly from ESP32 GPIO (current too high)

**Buzzer Driver Circuit Options**:

1. **NPN Transistor Driver** (recommended for Phase 1):
   - Transistor: 2N3904, 2N2222, or equivalent
   - Base resistor: 10kΩ (GPIO → resistor → base)
   - Emitter to GND
   - Collector to buzzer signal input
   - Buzzer VCC to 5V supply
   - Buzzer GND to GND
   - Flyback diode: 1N4148 across buzzer (cathode to 5V side) if buzzer has coil

2. **Logic-Level N-Channel MOSFET Driver** (alternative):
   - MOSFET: 2N7000, BS170, or IRLZ44N
   - Gate resistor: 10kΩ (GPIO → resistor → gate)
   - Gate pulldown: 10kΩ (gate → GND)
   - Drain to buzzer signal input
   - Source to GND
   - Buzzer VCC to 5V supply

### SparkFun BOB-12009 Level Converter

- **Status**: Likely not needed for Phase 1
- **Reason**: Both ESP32-S3 and VL53L0X use 3.3V I2C logic
- **Use case**: May be useful if future sensors require 5V I2C or if signal integrity issues arise
- **Recommendation**: Set aside for now; only use if I2C communication is unstable

### Arduino Nano ESP32 (ABX00083)

- **MCU**: ESP32-S3-MINI-1-N8 (dual-core Xtensa LX7, 240 MHz)
- **Flash**: 8 MB
- **RAM**: 512 KB SRAM
- **Operating voltage**: 3.3V logic (5V tolerant on some pins - verify per-pin)
- **Power input**: 
  - USB: 5V via USB-C connector (VUSB pin provides 5V)
  - VIN: 6-21V (onboard regulator steps down to 5V and 3.3V)
- **I2C**: Hardware I2C0 on A4 (SDA) and A5 (SCL)
- **PWM**: All GPIO pins support LEDC (LED Controller peripheral, up to 16 channels)
- **Current per GPIO**: 40 mA max source/sink (use external driver for high-current loads)
- **USB**: Native USB via ESP32-S3 (no external USB-serial chip)

**Power Output Pins**:
- **3V3**: 500 mA max (enough for VL53L0X + small peripherals)
- **VUSB**: Up to USB current limit (~500 mA typical, 2A if powered by high-current adapter)

---

## Wiring Notes and Best Practices

### I2C Bus

1. **Pull-up resistors**: VL53L0X modules typically include onboard pull-ups (4.7kΩ or 10kΩ). Check with multimeter if uncertain.
   - If missing, add 4.7kΩ resistors from SDA/SCL to 3.3V
   - Smaller resistors (2.2kΩ) may be needed for long wires or high-speed operation

2. **Wire length**: Keep I2C wires short (<1 meter recommended). Use twisted pair if longer runs are needed.

3. **Shielding**: In electrically noisy environments (near motors, fluorescent lights), use shielded cable for I2C and connect shield to GND at one end only.

### Power Distribution

1. **Common ground**: All components must share a common ground connection. Star ground topology is ideal (all grounds connect to a single point near the power supply).

2. **Decoupling capacitors**: 
   - 100nF ceramic capacitor across VL53L0X power pins (close to sensor)
   - 10µF electrolytic capacitor on ESP32 3V3 pin
   - 100-1000µF electrolytic on 5V supply rail (especially if using laser or LED strip)

3. **Power sequencing**: Ensure 3.3V and 5V rails are stable before ESP32 boots. Most regulators handle this automatically.

### GPIO Protection

1. **Flyback diodes**: Place 1N4148 or equivalent diode across any inductive load (relays, motors, coils). Not needed for piezo buzzers unless they have internal coils.

2. **Current limiting**: Always use resistors to limit current into LEDs (330Ω for standard 5mm LEDs at 5V).

3. **ESD protection**: Handle ESP32 and sensors with anti-static precautions. Ground yourself before touching pins.

### Testing and Troubleshooting

1. **Multimeter checks** (power off before measuring):
   - Verify 3.3V at VL53L0X VCC pin
   - Verify 5V at buzzer VCC pin
   - Verify continuity from all GND pins to common ground
   - Check I2C pull-ups: should measure ~3.3V on idle SDA/SCL lines

2. **Oscilloscope/Logic analyzer** (if available):
   - Check I2C waveforms: should see clean square waves, transitions between 0V and 3.3V
   - Verify I2C address appears on bus: 0x29 for VL53L0X
   - Check for clock stretching or NACK conditions (indicate communication problems)

3. **ESPHome logs**:
   - Look for "VL53L0X setup successful" message on boot
   - Check for "i2c scan found device at address 0x29" in logs
   - Monitor for sensor timeout errors or NaN readings

---

## Phase-by-Phase Hardware Checklist

### Phase 1: Sensor Validation

- [x] Arduino Nano ESP32
- [x] VL53L0X ToF sensor
- [x] 5V active buzzer module
- [x] NPN transistor or MOSFET (for buzzer driver)
- [x] 10kΩ resistors (2x: base/gate resistor + pulldown)
- [x] Jumper wires / breadboard or terminal base
- [x] USB-C cable (for power and programming)

### Phase 2: State Machine

- Same hardware as Phase 1 (logic only, no new components)

### Phase 3: Feedback Enhancements

- [ ] Green line laser module (532nm, 5V)
- [ ] Logic-level N-MOSFET (IRLZ44N or equivalent) for laser
- [ ] WS2812B LED strip (5V, or discrete red/yellow/green LEDs)
- [ ] 330Ω resistors (for DIN line or discrete LED current limiting)
- [ ] 100-1000µF capacitor (if using WS2812B strip)
- [ ] Additional 10kΩ resistor (gate pulldown for laser MOSFET)

### Phase 4: Home Assistant Integration

- No additional hardware required (software only)

### Phase 5: Mounting

- [ ] 3D-printed enclosure
- [ ] Mounting brackets/arms
- [ ] Screws, anchors, cable clips
- [ ] Weatherproof cable glands (if outdoor-exposed)

### Phase 6: Custom PCB

- [ ] Custom PCB (designed in KiCad, manufactured)
- [ ] ESP32-S3 module or chip
- [ ] SMD resistors, capacitors, transistors (per schematic)
- [ ] Screw terminals for external connections
- [ ] PCB standoffs and mounting hardware

---

## Safety and Compliance Notes

### Electrical Safety

- **Laser safety**: Class 2 lasers (<1 mW) are generally safe but should not be stared into. Use a diffuser lens for line projection (reduces point intensity).
- **Overcurrent protection**: Use a fuse or PTC resettable fuse on 5V supply line (1A rating recommended).
- **Enclosure**: All mains-voltage components (if hardwiring from garage power) must be in a grounded, enclosed box. **Consult an electrician if unsure.**

### FCC/CE Compliance

- **ESP32 modules** (like the one on Nano ESP32) are typically FCC/CE certified for RF emissions.
- **Hobby projects** for personal use generally do not require certification.
- **If selling or distributing**: Consult regulatory requirements for your region.

### Environmental

- **Operating temperature**: ESP32-S3: -40°C to 85°C (commercial grade). Most garages are within this range.
- **Humidity**: VL53L0X is not waterproof. Enclosure should be splash-resistant if near garage door or in humid climates.
- **Dust**: Ensure sensor window is kept clean (dust can scatter IR light and reduce accuracy).

---

## Changelog

- **2024-11-04**: Initial hardware documentation (Phase 1)

