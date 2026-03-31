# 🎮 Falling Letters — x86 Assembly Game

A real-time console-based arcade game written entirely in **x86 Assembly (NASM)**, running in DOS. Random letters fall from the top of the screen and you must catch them with a moving box at the bottom.

---

## 📖 About the Project

This project was developed as part of the **Computer Organization & Assembly Language (CS-2003)** course at FAST-NUCES. It demonstrates low-level programming concepts including direct video memory access, hardware interrupt handling, and real-time game logic — all written in pure x86 Assembly with no high-level language support.

---

## 🕹️ Gameplay

- 5 letters fall simultaneously from random columns at different speeds
- Move your box left and right to catch them before they hit the bottom
- Catching a letter increases your **Score**
- Missing a letter increases your **Missed** count
- The game ends when you miss **10 letters**
- Press **A** on the Game Over screen to **restart**
- Press **Escape** to quit at any time

---

## ⌨️ Controls

| Key | Action |
|---|---|
| `←` Left Arrow | Move box left |
| `→` Right Arrow | Move box right |
| `ESC` | Exit the game |
| `A` | Restart (on Game Over screen) |

---

## ✨ Features

- 🔤 5 independently falling letters with different speeds and colors
- 🎲 Randomized starting column for each letter (seeded via BIOS timer)
- 🏆 Live score and missed count displayed on screen
- 📺 Direct video memory writes to `0xB800` segment (no BIOS print calls)
- ⚡ Custom **Timer ISR** (IRQ 0) for real-time letter movement
- ⌨️ Custom **Keyboard ISR** (IRQ 1) for responsive input
- 🔁 Full game restart without re-running the program
- 🎨 Color-coded letters using different video attributes

---

## 🏗️ Implementation Details

| Component | Description |
|---|---|
| **Video Memory** | Direct writes to `0xB800:offset` for all rendering |
| **Timer ISR** | Hooks INT 8h to move letters on every tick |
| **Keyboard ISR** | Hooks INT 9h to handle arrow keys and escape |
| **Random Generator** | LCG (Linear Congruential Generator) seeded via BIOS `INT 1Ah` |
| **Box Movement** | Wraps around screen edges (column 0 ↔ column 79) |
| **Collision Detection** | Compares letter position with box position at bottom row |

---

## 📁 Project Structure

```
Falling-Letters-ASM/
├── falling_letters.asm      # Full source code
└── README.md
```

---

## ⚙️ Tech Stack

- **Language:** x86 Assembly (NASM syntax)
- **Target:** DOS / DOSBox
- **Assembler:** NASM
- **Display:** Direct CGA/VGA video memory (`0xB800`)

---

## 🚀 Setup & Build

### Prerequisites
- [NASM](https://www.nasm.us/) assembler
- [DOSBox](https://www.dosbox.com/) emulator

### Assemble

```bash
nasm -f bin falling_letters.asm -o falling_letters.com
```

### Run

```bash
# Open DOSBox, mount the folder, then run:
falling_letters.com
```

---

## 👤 Author

**Roll No:** 23L-0527  
**Section:** BCS-3A  
**Course:** Computer Organization & Assembly Language — FAST-NUCES
