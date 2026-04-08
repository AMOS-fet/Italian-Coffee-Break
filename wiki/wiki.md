#   HYPRLAND CHEATSHEET

> **Legend:** **** = SUPER Key

##   APPLICATIONS
| Keybind | Action |
| :--- | :--- |
| ** + Return** |   Open Terminal |
| ** + Space** |   App Launcher (Wofi) |
| ** + F** |   File Manager (Yazi/TUI) |
| ** + SHIFT + F** |   File Manager (GUI) |
| ** + E** |   Web Browser |
| ** + D** |   Dismiss Notifications |

##   WINDOW CONTROLS
| Keybind | Action |
| :--- | :--- |
| ** + Q** |   Kill Active Window |
| ** + W** |   Toggle Fullscreen |
| ** + SHIFT + W** |   Toggle Floating Mode |
| ** + Arrows** |   Move Focus |
| ** + Left Click** |   Move Window (Mouse) |
| ** + Right Click** |   Resize Window (Mouse) |

##   MOVE & RESIZE
| Keybind | Action |
| :--- | :--- |
| ** + CTRL + SHIFT + Arrows** |   Move Window Position |
| ** + CTRL + Up/Down** |   Resize Active Window |

##   WORKSPACES
| Keybind | Action |
| :--- | :--- |
| ** + CTRL + Left/Right** |   Cycle Workspace |
| **CTRL + ALT + Left/Right** |   Move Window to Workspace |
| ** + S** |   Toggle Scratchpad (Special) |
| ** + SHIFT + S** |   Move to Scratchpad |

---

#  LAZYVIM CHEATSHEET

> **Legend:** **SPC** = `<leader>` (Spacebar), **RET** = Enter Key, **ESC** = Escape Key

##   FILE & FOLDER MANAGEMENT (NEO-TREE)
*Note: Ensure your cursor is inside the file explorer sidebar to use single-letter commands.*

| Keybind | Action |
| :--- | :--- |
| **SPC + E** |   Toggle File Explorer |
| **A** |   Add New File/Folder |
| **D** |   Delete File/Folder |
| **R** |   Rename File/Folder |
| **X** | ✂  Cut File (to move) |
| **P** |   Paste File |

##   WINDOW MANAGEMENT (SPLITS)
| Keybind | Action |
| :--- | :--- |
| **SPC + \|** |   Split Screen Vertically |
| **SPC + -** |   Split Screen Horizontally |
| **CTRL + Arrows** |   Move Focus Between Splits |
| **SPC + B + D** |   Close Current Window (Buffer Delete) |

## 󰍽  TEXT SELECTION (VISUAL MODE)
*Note: Press **ESC** to ensure you are in Normal Mode before using these.*

| Keybind | Action |
| :--- | :--- |
| **V + I + W** |   Select Current Word |
| **SHIFT + V** |   Select Entire Line |
| **G + G + SHIFT + V + SHIFT + G** |   Select Entire File |

##   EDITING (COPY, CUT, PASTE)
| Keybind | Action |
| :--- | :--- | 
| **Y** |   Copy (Yank) Selection |
| **Y + Y** |   Copy Entire Line |
| **D** | ✂  Cut/Delete Selection |
| **D + D** | ✂  Cut/Delete Entire Line |
| **P** |   Paste After Cursor |
| **SHIFT + P** |   Paste Before Cursor |
| **U** |   Undo |
| **CTRL + R** |   Redo |

##   SEARCH & REPLACE
| Keybind | Action |
| :--- | :--- | 
| **/ + [word] + RET** |   Search in Current File |
| **N / SHIFT + N** |   Go to Next / Previous Match |
| **:%s/old/new/gc + RET** |   Replace in File (with confirmation) |
| **SPC + S + G** |   Search inside Entire Project (Grep) |

##   PYTHON ENVIRONMENT
| Keybind / Command | Action |
| :--- | :--- | 
| **SPC + F + T** |   Toggle Integrated Terminal |
| **`python -m venv .venv`** |   Create Virtual Env (Terminal) |
| **`source .venv/bin/activate`** |   Activate Env (Terminal) |
| **`pip install [pkg]`** |   Install Package (Terminal) |
| **SPC + C + V** |   Choose Venv for IDE Autocompletion |
| **:!python % + RET** |   Run Current Python Script |
