# Italian-Coffee-Break
## ☕ Camera Café Dotfiles: A Hyprland Setup
Welcome to the corporate office of your desktop.  

Inspired by the iconic sitcom Camera Café, this Hyprland dotfiles repository is designed to be as dynamic, chaotic, yet surprisingly functional as the 17th floor office.

Whether you are trying to look busy like Luca and Paolo in front of the coffee machine, or you actually need to get serious work done like Silvano, this setup provides a modular, aesthetically pleasing, and lightning-fast Wayland experience.

## 🏢 The Concept
Just like the famous coffee area where all the corporate drama unfolds, your desktop should be the central hub of your workflow. 
- Fast and Unforgiving: Powered by Hyprland, for a tiling experience that doesn't waste time.
- Modular: Managed via GNU Stow, keeping your configurations clean and separate from your home directory clutter. 
- Customizable: Easily change themes and accents depending on your mood (or depending on whether the Director is walking by).

## 🛠️ Installation
1. **The Golden Rule:** Placement\
   For the automated installer and symlinks to work correctly, this repository must be cloned exactly into your `$HOME` directory. 
> [!CAUTION]
> Do not place it in subfolders

````Bash
cd ~
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git ~/dotfiles
````

2. **The Installer Script**
   Once the repository is in place, you can run the automated installer.
   The installer is designed to do two main things: 
   - Fetch Dependencies: It will prompt you to install the necessary packages, core programs, and utilities required for the desktop environment. 
   - Stow Configurations: Instead of brutally copying files into your `~/.config` directory, the script uses GNU Stow. This creates intelligent symlinks from the `~/dotfiles` folder to your system. If you update a file in `~/dotfiles`, your system updates instantly, keeping your git tracking clean and safe.
   
 ```` Bash
 cd ~/dotfiles
 chmod +x install.sh./install.sh
 ```` 

## 🎨 Theming and Accent Colors
 Whether you want a Che Guevara poster or a Pooh one, you can easily change the look and feel of your desktop to whatever you like.  
 
 The theming engine allows you to switch between different color palettes and accent colors (affecting Waybar, borders, Rofi, and the terminal) with minimal effort. 
 
 **How to change it:** Simply click on the button with the OS logo located on your Waybar to open the theme selector and pick your new corporate identity.
 
 When you change a theme or an accent color, the system dynamically reloads the affected components, no need to restart the entire Hyprland session. Just grab your coffee and watch the colors shift.
 
## 🔧 Local Configurations
 Git repositories are great, but monitor resolutions, hardware quirks, and personal keybinds shouldn't be pushed to the public repo.  
 
 To solve this, the setup supports Local Overrides. You can safely tweak your machine-specific settings without dirtying your git tree.
 
 **How it works:** For critical configuration files, the system looks for a local equivalent.
 
 For example, if you want to set up your specific monitors or workspaces, do not edit the main `hyprland.conf` directly.  
 Instead edit the local file (e.g. `local.conf`). Add your machine-specific rules (like monitor=DP-1, 2560x1440@144, 0x0, 1).  
 
 The main configuration file will automatically source this local file if it exists. These local files are ignored by `.gitignore`, meaning you can confidently run git pull to get the latest updates for the main setup without ever losing your personal hardware configurations.

> Johnatan, io secondo te, sono oberato?
