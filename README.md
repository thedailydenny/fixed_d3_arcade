# d3-arcade (Qbox + ox_target Fix)

A retro arcade system for GTA V, based on the original [rcore_arcade](https://github.com/Xogy/rcore_arcade) and heavily modified for modern frameworks.

---

### 🛠 Credits & Contributions
* **Original Concept:** [rcore_arcade](https://github.com/Xogy/rcore_arcade) by Xogy.
* **Qbox Version & Logic:** [d3st1nyh4x](https://github.com/d3st1nyh4x) (Author of this specific fork).
* **Fix & Compatibility:** **thedailydenny** (Updated for Qbox + ox_target integration).

---

### 📝 About This Fork
This version is specifically tailored for the **Qbox Project** ecosystem. It bridges the gap between the standalone/ESX logic of the original script and the high-performance requirements of Qbox.

**Key Changes in this Fix:**
* **Framework Dependency:** Fully converted to Qbox-specific functions.
* **Interaction System:** Replaced markers/3D text with **ox_target** for better performance and a cleaner UI.
* **EmulatorJS Integration:** Includes the PR for emulatorjs, allowing real ROMs to be played in-game.

---

### 🕹 Machine Types
You can define three categories of arcade machines in the config:
1.  **RetroMachine:** Classic 8-bit/16-bit titles.
2.  **GamingMachine:** More modern emulated experiences.
3.  **SuperMachine:** An aggregate list containing all available games.

### ⚙ Game Configuration
Adding games is straightforward. Choose between **DOSBOX** or **EJS** (EmulatorJS) and fill in the parameters:

DOSBOX:
```
    {
        -- this is the name in the menu/ game list
        name = "Duke Nukem 3D", 
        -- link to msdos page, link to rom, and executable (in this zip, there is an EXE called DUKE3D which starts the game. This may be a BAT in some cases)
        link = string.format("nui://d3-arcade/html/msdos.html?url=%s&params=%s", "https://www.retrogames.cz/dos/zip/duke3d.zip", "./DUKE3D.EXE"),
    }
```
EJS:
```
    {
        -- this is the name in the menu/ game list
        name = "Contra III",
        -- link to ejs page, link to rom, core, uniquename, and unique id (for net play)
        link = string.format("nui://d3-arcade/html/ejs.html?url=%s&params=%s&name=%s&id=%s", "https://static.emulatorgames.net/roms/super-nintendo/Contra%20III%20-%20The%20Alien%20Wars%20(U)%20[!].zip", "snes", "Contraiii-snes", "4205"),
    },
```
CPU/GPU, what do they do?

the cpu determines how long the initial loading bar lasts<br>
the gpu determines the resolution of the screen

Works on QBOX + OX Target

MISC:

/testgames opens a "super computer" with all games for testing purposes, restricted to admins.

Dependencies

OX_target<br>
[https://github.com/d3st1nyh4x/MenuAPI (fork fixed for large lists)](https://github.com/overextended/ox_target)
