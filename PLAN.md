# Garage Parking Assistant - Project Plan

## Purpose

A wall-mounted garage parking assistant that helps drivers center their vehicle and stop at the optimal distance. The system provides visual and audible feedback that becomes progressively more urgent as the vehicle approaches, signals STOP at the target position, and warns BACK UP if the vehicle overshoots. All parking logic runs locally on the ESP32 and continues to work even if Home Assistant or Wi-Fi connectivity is lost.

## Requirements

### Functional Requirements

1. **Distance Measurement**: Accurate distance sensing from garage wall to vehicle front
   - Target accuracy: ±5 inches (±12.7 cm)
   - Operating range: 25 cm to 2 m (dependent on sensor configuration)
   - Update rate: at least 4 Hz for responsive feedback

2. **Parking Zones**: Multiple feedback zones with configurable thresholds
   - **Zone 1 (Far)**: > 1.2 m - No alert, safe to approach
   - **Zone 2 (Approaching)**: 0.7-1.2 m - Slow beep, visual feedback begins
   - **Zone 3 (Close)**: 0.45-0.7 m - Medium beep, more urgent visual
   - **Zone 4 (Final)**: 0.25-0.45 m - Fast beep, nearly at target
   - **STOP Zone**: 0.15-0.25 m - Target position, continuous signal
   - **BACK UP Zone**: < 0.15 m - Overshoot warning, urgent alarm

3. **Feedback Systems**
   - **Audio**: Piezo buzzer with variable beep patterns (slow → fast → continuous)
   - **Visual**: Green line laser for centering guidance (future phase)
   - **Visual**: LED status indicators showing zones (future phase)

4. **Centering Assistance**
   - Horizontal line laser projected on vehicle hood/windshield
   - Driver aligns vehicle when laser appears centered

5. **State Management**
   - Hysteresis on zone transitions to prevent oscillation
   - Filtering to handle noisy or intermittent readings
   - Lost-reading detection and safe fallback behavior
   - Automatic activation/deactivation based on garage door state

6. **Standalone Operation**
   - All parking logic runs on ESP32
   - No dependency on Home Assistant for core functionality
   - Operates during network/Wi-Fi outages

### Non-Functional Requirements

1. **Reliability**: Must work consistently in all weather conditions
2. **Responsiveness**: Feedback latency < 250 ms
3. **Safety**: Fail-safe behavior on sensor failures (e.g., disable rather than give false readings)
4. **Maintainability**: Easy to recalibrate for different vehicles
5. **Integration**: Home Assistant integration for configuration, diagnostics, and automation triggers

### Calibration Vehicle

- **Primary vehicle**: Mazda CX-5
- **Sensor mounting**: Garage wall, front-facing, ≤ 24 inches height (approximately bumper level)
- **Target stop distance**: Configurable, initially ~0.20 m (8 inches) from sensor

## Architecture

### Hardware Components

```
┌─────────────────────────────────────────────────────────────┐
│                      Garage Wall                             │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  VL53L0X ToF │  │    Buzzer    │  │  Green Laser │     │
│  │    Sensor    │  │   (5V PWM)   │  │  (via MOSFET)│     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │ I2C             │ GPIO            │ GPIO          │
│         │                 │                 │               │
│  ┌──────┴─────────────────┴─────────────────┴───────┐     │
│  │         Arduino Nano ESP32 (ESP32-S3)             │     │
│  │  - I2C: A4 (SDA), A5 (SCL)                        │     │
│  │  - GPIOs for buzzer, laser, LEDs                  │     │
│  │  - Wi-Fi for Home Assistant (optional)            │     │
│  └───────────────────────────────────────────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Software Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Home Assistant (Optional)                 │
│  - Dashboard & configuration UI                              │
│  - Garage door state monitoring                              │
│  - Vehicle detection integration (Reolink)                   │
│  - Historical data & diagnostics                             │
└────────────────────────┬────────────────────────────────────┘
                         │ Wi-Fi / API
                         │ (optional)
┌────────────────────────┴────────────────────────────────────┐
│                    ESP32 (ESPHome)                           │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Parking State Machine                      │ │
│  │  - Zone determination with hysteresis                   │ │
│  │  - Reading filter & validation                          │ │
│  │  - Feedback coordination (buzzer, laser, LEDs)          │ │
│  │  - Lost-reading detection                               │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ VL53L0X I2C  │  │Buzzer Control│  │ Laser/LED    │     │
│  │   Driver     │  │   (PWM/GPIO) │  │   Control    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Sensor Reading** → VL53L0X I2C read (every 250 ms)
2. **Filtering** → Moving average + outlier rejection
3. **Zone Detection** → Current distance mapped to zone with hysteresis
4. **State Machine** → Zone transitions trigger feedback changes
5. **Feedback Output** → Buzzer beep pattern + laser + LEDs updated
6. **Telemetry** → Distance, zone, and diagnostics published to Home Assistant (if connected)

## Project Phases

### Phase 1: Sensor Validation ✓ (This PR)

**Goal**: Verify VL53L0X sensor accuracy and reliability with the Mazda CX-5.

**Success Criteria**:
- [ ] ESPHome configuration loads and compiles without errors
- [ ] Sensor consistently detects vehicle from 25 cm to 1.2 m (minimum range)
- [ ] Test long-range mode: measure maximum reliable detection distance on CX-5 bumper
- [ ] Distance readings stable within ±5 cm when vehicle is stationary
- [ ] Readings update at ≥4 Hz
- [ ] Web server shows real-time distance in cm and inches
- [ ] Moving average and stability statistics (min/max/std-dev window) visible in logs/web UI
- [ ] Lost-reading detection triggers within 2 seconds of sensor occlusion

**Deliverables**:
- [x] `PLAN.md` - This document
- [x] `HARDWARE.md` - Pin assignments and wiring diagrams
- [x] `esphome/garage-parking-assistant.yaml` - Phase 1 configuration
- [x] `secrets.yaml.example` - Template for Wi-Fi credentials
- [x] `.cursor/rules` - AI agent guidelines
- [x] Updated `README.md` - Project introduction and Phase 1 instructions

**Test Procedure**:
1. Flash ESP32 via USB
2. Connect to web server (`http://garage-parking-assistant.local`)
3. Verify distance readings with vehicle at multiple positions
4. Record maximum reliable range in both default and long-range mode
5. Test against dark/curved bumper sections
6. Document any dead zones or unreliable ranges

**Open Questions**:
- Does long-range mode provide sufficient range (>1.2 m) on the CX-5's dark bumper?
- Is the 3.3V power sufficient for the VL53L0X, or do we need external power?
- Should the level converter be used despite both devices being 3.3V?

---

### Phase 2: Parking State Machine

**Goal**: Implement multi-zone parking logic with hysteresis, filtering, and STOP/BACK UP states.

**Success Criteria**:
- [ ] Zone transitions work smoothly with configurable hysteresis (e.g., 5 cm deadband)
- [ ] No oscillation between zones when vehicle is stationary at boundary
- [ ] STOP signal activates at target distance (0.15-0.25 m)
- [ ] BACK UP warning triggers if vehicle passes STOP zone (< 0.15 m)
- [ ] Lost readings detected after 2 seconds, system enters safe state
- [ ] State machine continues operating without Wi-Fi/Home Assistant
- [ ] Zone thresholds configurable via ESPHome substitutions

**Deliverables**:
- State machine implementation in ESPHome YAML (lambda functions)
- Comprehensive logging of zone transitions and state changes
- Documentation of hysteresis and filtering parameters
- Test cases for boundary conditions

**Open Questions**:
- What hysteresis value prevents oscillation without feeling sluggish? (test 5 cm, 10 cm)
- Should BACK UP zone use different feedback than STOP? (flash vs. solid, different tone)
- How should system behave if readings are lost mid-parking?

---

### Phase 3: Buzzer, LED, and Laser Feedback

**Goal**: Add audible and visual feedback coordinated with parking zones.

**Success Criteria**:
- [ ] Buzzer beep rate increases with proximity (Zone 2: slow → Zone 4: fast → STOP: continuous)
- [ ] Green line laser activates in Zone 2 and remains on through STOP
- [ ] LED indicators show current zone (green → yellow → red)
- [ ] BACK UP warning uses distinct urgent pattern (fast flash + alarm tone)
- [ ] All feedback outputs driven through appropriate MOSFETs/transistors
- [ ] Feedback can be toggled on/off from Home Assistant without breaking state machine

**Deliverables**:
- Buzzer control via PWM with multiple tone patterns
- Laser MOSFET driver circuit and GPIO control
- LED control (WS2812B strip or discrete LEDs)
- Updated wiring diagram with all feedback components
- Video demonstration of complete feedback sequence

**Open Questions**:
- What beep frequency is most attention-grabbing without being obnoxious? (test 1-4 kHz)
- Should laser be solid or pulsing as car approaches?
- LED strip vs. discrete LEDs: which is clearer in bright garage light?

---

### Phase 4: Home Assistant Integration

**Goal**: Full HA integration for configuration, automation, and diagnostics.

**Success Criteria**:
- [ ] Dashboard showing current distance, zone, and sensor status
- [ ] Automatic activation when garage door opens
- [ ] Integration with Reolink camera vehicle detection (optional trigger)
- [ ] Configurable zone thresholds via HA UI (no YAML edits needed)
- [ ] Historical distance graphs for parking analysis
- [ ] Diagnostic sensors: signal quality, reading stability, error counts
- [ ] Notifications on sensor failures or calibration drift

**Deliverables**:
- Home Assistant dashboard YAML
- Automation examples (garage door trigger, vehicle detection)
- ESPHome API entities for all configurable parameters
- Diagnostic sensor definitions
- HA configuration documentation

**Open Questions**:
- Should system auto-disable when garage door is closed, or stay in standby?
- How to handle multiple vehicles with different stop distances? (profiles in HA?)
- Should Reolink detection be a hard requirement or optional enhancement?

---

### Phase 5: Mechanical Mounting

**Goal**: Permanent, adjustable mounting for sensor, laser, and buzzer.

**Success Criteria**:
- [ ] Sensor mounted at ≤24 inches height, level with CX-5 bumper
- [ ] Sensor alignment adjustable (pitch, yaw) for fine-tuning aim
- [ ] Laser aligned to project horizontal line across hood/windshield at driver's eye level
- [ ] Weatherproof enclosure for ESP32 and electronics
- [ ] Cable management for power and sensor wiring
- [ ] Mounting does not obstruct garage door operation or vehicle clearance

**Deliverables**:
- 3D-printed enclosure CAD files (STEP, STL)
- Mounting bracket design (wall-mount or rail-mount)
- Assembly instructions with photos
- Cable routing and strain relief design
- Alignment procedure document

**Open Questions**:
- Wall-mount vs. ceiling-mount: which provides better sensor angle?
- Does vibration from garage door affect sensor readings?
- How to handle multi-bay garage or adjustable parking positions?

---

### Phase 6: Custom PCB

**Goal**: Replace breadboard/terminal base with a custom PCB for reliability and compactness.

**Success Criteria**:
- [ ] PCB integrates ESP32 module, sensor connector, MOSFET drivers, and power regulation
- [ ] I2C pull-up resistors, bypass capacitors, and protection diodes included
- [ ] Screw terminals for external connections (power, buzzer, laser, LEDs)
- [ ] Fits in 3D-printed enclosure from Phase 5
- [ ] PCB design reviewed and validated (DRC, ERC checks pass)
- [ ] Prototype boards ordered and tested before final production run

**Deliverables**:
- KiCad schematic and PCB layout files
- Gerber files for manufacturing
- Bill of materials with supplier part numbers
- Assembly instructions and component placement diagram
- Test procedure for PCB bring-up

**Open Questions**:
- ESP32 module vs. raw ESP32-S3 chip: which is easier to solder/replace?
- USB-C or Micro-USB for programming port?
- Should PCB include backup power (supercap) for graceful shutdown detection?

---

## Technical Notes

### VL53L0X Time-of-Flight Sensor

- **Default mode range**: ~1.2 m reliable distance on most targets
- **Long-range mode**: Up to ~2 m on reflective/flat targets
  - **WARNING**: Long-range mode performance drops significantly on dark or curved surfaces (like car bumpers)
  - **Required testing**: Must validate against Mazda CX-5 bumper to confirm usable range
- **Fallback sensors** (if VL53L0X insufficient):
  - **VL53L1X**: Improved range (~4 m) and accuracy, same I2C interface
  - **TFmini-S**: UART lidar, ~12 m range, more expensive but very reliable
- **Power**: 3.3V recommended (2.6V to 3.5V operating range)
  - Nano ESP32 provides clean 3.3V output
  - Level converter likely unnecessary (both ESP32-S3 and VL53L0X are 3.3V I2C)

### Buzzer Driver

- **5V active buzzer module**: Requires 5V supply and control signal
- **GPIO direct drive**: ❌ **NOT RECOMMENDED** - ESP32 GPIO cannot safely source enough current
- **Recommended driver**: NPN transistor (e.g., 2N2222, 2N3904) or logic-level MOSFET (e.g., 2N7000, BS170)
  - Base/gate driven from ESP32 GPIO (3.3V logic)
  - Collector/drain to buzzer positive
  - Buzzer negative and emitter/source to GND
  - Flyback diode (1N4148 or equivalent) across buzzer for inductive kick protection

### Power Considerations

- **Phase 1**: USB power during development
- **Phase 2+**: Permanent 5V supply (wall adapter or hardwired from garage power)
- **Current budget**:
  - ESP32: ~80-160 mA (depends on Wi-Fi usage)
  - VL53L0X: ~10 mA
  - Buzzer: ~30 mA
  - Laser: ~50-150 mA (TBD based on selected module)
  - LEDs: ~20-60 mA per LED (depends on count and brightness)
  - **Total estimate**: ~500 mA peak (2.5W @ 5V) - use ≥1A supply for headroom

### Arduino Nano ESP32 (ABX00083)

- **MCU**: ESP32-S3 dual-core, 240 MHz
- **Logic level**: 3.3V (5V tolerant on some pins - check datasheet)
- **I2C pins**: A4 (SDA), A5 (SCL) - hardware I2C0
- **USB**: Native USB via ESP32-S3 (no CH340 serial converter)
- **Programming**: Arduino IDE, PlatformIO, or ESPHome

---

## Open Questions Tracker

This section tracks unresolved questions that may affect design decisions in future phases. Questions are marked resolved when answered through testing or design choices.

### Phase 1 Questions

1. **[OPEN]** Does VL53L0X long-range mode provide ≥1.2 m range on the Mazda CX-5's dark bumper?
   - **Test**: Compare default vs. long-range mode readings at multiple distances
   - **Acceptance**: If long-range achieves 1.5 m+, use it; otherwise evaluate VL53L1X

2. **[OPEN]** Is a level converter needed between ESP32 and VL53L0X?
   - **Current assumption**: No, both are 3.3V I2C
   - **Test**: Check signal integrity with oscilloscope or logic analyzer if readings are unstable

3. **[OPEN]** What is the optimal sensor mounting height for CX-5 bumper detection?
   - **Current plan**: ≤24 inches (bumper height)
   - **Test**: Try 18", 20", 24" heights and measure detection consistency

4. **[OPEN]** How much does garage ambient light affect VL53L0X readings?
   - **Test**: Measure with lights on/off, garage door open/closed

### Phase 2 Questions

5. **[OPEN]** What hysteresis value prevents zone oscillation without feeling sluggish?
   - **Options**: 5 cm, 10 cm, 15 cm deadbands
   - **Test**: Have driver park repeatedly and adjust until transitions feel natural

6. **[OPEN]** Should lost readings trigger immediate alarm or silent fallback?
   - **Safety tradeoff**: Alarm warns driver but may be annoying on brief occlusions
   - **Test**: Simulate lost readings and observe driver response

### Phase 3 Questions

7. **[OPEN]** What buzzer tone frequency is optimal (attention-grabbing but not annoying)?
   - **Test range**: 1 kHz - 4 kHz
   - **Consider**: Different tones for different zones?

8. **[OPEN]** Should green laser be solid or pulsing?
   - **Solid**: Easier to align to
   - **Pulsing**: More attention-grabbing, less eye strain
   - **Test**: Try both and ask driver preference

### Phase 4 Questions

9. **[OPEN]** How to handle multiple vehicles with different stop distances?
   - **Options**: 
     - Manual mode switch in HA (vehicle A/B profiles)
     - Automatic detection via Reolink camera + license plate recognition
     - Single compromise distance for all vehicles

10. **[OPEN]** Should system auto-disable when garage door closes?
    - **Pro**: Saves power, prevents false alerts
    - **Con**: May miss vehicle if door state sensor fails

### Phase 5 Questions

11. **[OPEN]** Wall-mount vs. ceiling-mount for sensor?
    - **Wall**: Easier wiring, clearer line of sight
    - **Ceiling**: Less obtrusive, better for multi-vehicle garages

12. **[OPEN]** Does garage door vibration affect sensor accuracy?
    - **Test**: Measure readings while door is in motion

### Phase 6 Questions

13. **[OPEN]** ESP32 module vs. raw ESP32-S3 chip on PCB?
    - **Module (e.g., ESP32-S3-WROOM)**: Easier to source, certified RF, easier to replace
    - **Raw chip**: Smaller footprint, cheaper at scale, requires RF layout expertise
    - **Decision pending**: Evaluate after Phase 5 space constraints known

14. **[OPEN]** Should PCB include backup power (supercap) for network loss detection?
    - **Use case**: Detect Wi-Fi outage and log it for diagnostics
    - **Tradeoff**: Adds cost and complexity

---

## Success Metrics

### Performance Metrics (measurable targets)

- **Distance accuracy**: ±5 cm at target stop distance (0.20 m)
- **Response time**: ≤250 ms from vehicle movement to feedback change
- **Zone transition smoothness**: No oscillation when stationary within 3 cm of boundary
- **Sensor uptime**: ≥99% (no more than 1 minute downtime per day)
- **False positive rate**: <1 per week (unexpected STOP alerts with no vehicle)

### Usability Metrics (subjective, to be validated by driver)

- **Ease of centering**: Driver can center vehicle within ±15 cm using laser guide
- **Confidence at STOP**: Driver trusts STOP signal without needing to check distance manually
- **Alert clarity**: Driver can distinguish zone changes by audio pattern alone (no visual)

### Reliability Metrics

- **Power-on self-test**: System detects sensor failures within 10 seconds of boot
- **Network independence**: Full parking functionality during Wi-Fi outage
- **Calibration stability**: Stop distance drifts <2 cm per month without recalibration

---

## Future Enhancements (Beyond Phase 6)

These are ideas for future iterations, not committed to the current plan:

1. **Multiple vehicle profiles**: Store stop distances for different vehicles, switch via HA or RFID tag
2. **Occupancy detection**: Detect when parking spot is occupied and disable system
3. **Backup sensors**: Dual sensors for redundancy (left/right or primary/backup)
4. **Voice feedback**: Spoken prompts ("Slow down", "Stop", "Back up") via I2S DAC and speaker
5. **Mobile app**: Direct control and configuration without Home Assistant
6. **Data analytics**: Track parking patterns, optimize zone thresholds over time
7. **Integration with car**: OBD-II connection to detect engine running state
8. **Emergency stop**: Large physical STOP button for manual override

---

## References

- **Original project**: [quintencls/esphome-parking-assistant](https://github.com/quintencls/esphome-parking-assistant) (MIT License)
- **ESPHome documentation**: https://esphome.io/
- **VL53L0X datasheet**: [STMicroelectronics VL53L0X](https://www.st.com/resource/en/datasheet/vl53l0x.pdf)
- **Arduino Nano ESP32**: [Official page](https://docs.arduino.cc/hardware/nano-esp32/)

---

## Changelog

- **2024-11-04**: Initial project plan created (Phase 1 documentation)
