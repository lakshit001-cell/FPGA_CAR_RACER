# 🏎️ FPGA Time-Travel Racer (Verilog)

A real-time car racing game implemented on FPGA using **Verilog**, featuring VGA-based rendering, sprite management, pseudo-random behavior, and hardware-level collision detection.

- **Course**: COL215 (Digital Logic & System Design) — IIT Delhi  
- **Focus**: Rival Car Integration (Part III)  

---

## 📌 Project Overview

The game features a **player-controlled main car** navigating a scrolling road while avoiding a dynamically spawning **rival car**.

Challenges addressed:
- Pixel-level rendering within hardware constraints  
- Memory-efficient sprite handling using ROMs  
- Real-time collision detection within clock cycles  
- Handling asynchronous button inputs  

---

## 🛠️ Hardware Architecture

### 1️⃣ VGA Display Engine

- Generates:
  - **HS (Horizontal Sync)**  
  - **VS (Vertical Sync)**  

- Operates on a **pixel-by-pixel basis**:
  - Uses `hor_pix` and `ver_pix` coordinates  
  - Determines which sprite layer to render  

---

### 2️⃣ Sprite Layering & ROMs

Sprites are stored in **Single Port ROMs** initialized via `.coe` files.

Rendering follows a **priority-based MUX pipeline**:

- **Top Layer** → Main Car (Player)  
- **Middle Layer** → Rival Car (AI)  
- **Base Layer** → Scrolling Background  

---

### 3️⃣ Pseudo-Random Number Generator (PRNG)

- Implemented using an **8-bit Linear Feedback Shift Register (LFSR)**  
- Generates random horizontal positions for the rival car  

**Constraints:**
- Range: **44px to 104px**  
- Ensures the rival remains within road boundaries  

---

## 🚀 Key Features

- **Dynamic Scrolling**  
  - Reverse vertical scrolling to simulate motion  

- **Hitbox Collision Detection**  
  - Real-time bounding-box overlap detection  

- **Finite State Machine (FSM)**  
  Handles game states:
  - `START` → Waiting for input  
  - `PLAY` → Active gameplay  
  - `CRASH` → Collision detected  

---

## 🎮 Controls & I/O

| Input  | Action                  |
|--------|------------------------|
| BTNC   | Reset / Restart Game   |
| BTNL   | Move Left              |
| BTNR   | Move Right             |

### Display Output
- **VGA Port**  
  - 12-bit RGB:
    - 4-bit Red  
    - 4-bit Green  
    - 4-bit Blue  

---

## 📂 File Structure

```
├── Display_sprite.v   # Core rendering + VGA sync logic
├── rival_car_rom      # ROM for enemy car sprite
├── main_car_rom       # ROM for player car sprite
├── bg_rom             # Background texture (road)
└── README.md
```

---

## ⚙️ Technical Specifications

- **Background Dimensions** → $160 \times 240$ pixels  
- **Main Car Dimensions** → $14 \times 16$ pixels  
- **Road Boundary** → 44px to 104px  
- **Refresh Rate** → 60 Hz (VGA Standard)  
- **Color Depth** → 12-bit (4096 colors)  

---

## 🧠 Implementation Logic

### 🔹 Collision Detection

```verilog
if ((main_car_x < rival_car_x + rival_width) && 
    (main_car_x + main_width > rival_car_x) &&
    (main_car_y < rival_car_y + rival_height) && 
    (main_car_y + main_height > rival_car_y)) begin
        collision_detected <= 1;
end
```

- Uses **bounding box overlap logic**  
- Executed in real-time during rendering  

---

## 🧩 Key Concepts Demonstrated

- FPGA-based system design  
- VGA signal generation and raster scanning  
- Memory-mapped sprite rendering  
- Hardware random number generation (LFSR)  
- FSM-based game control logic  
- Real-time collision detection  

---

## 📊 Summary

This project demonstrates:

- Real-time graphics rendering on FPGA  
- Efficient hardware resource utilization  
- Integration of control logic, memory, and display systems  
- Practical implementation of digital design concepts in an interactive application  

---

## 📌 Note

This project showcases how **low-level hardware design** can be used to build fully interactive real-time systems without relying on high-level software frameworks.