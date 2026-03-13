# Experimental ``silverblue-tr`` Build  

This is an experiment to build my personal Fedora Silverblue ``bootc`` image without using BlueBuild.
The reasons to do this are primarily to leverage some neat things from Bluefin/Universal Blue build patterns such as

- Automatically rebuild when the base image updates via RenovateBot
- Building Software Bill of Materials (SBOM)
- Enabling separate testing/production streams


## About ``silverblue-tr``

This image is [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) with 
customizations from [Bluefin](https://projectbluefin.io) and
own personal preferences baked in to the image.  Its goals are to make provisioning new devices simpler, and to
keep a consistent baseline of applications between them.

These are the important features of this image:

- "Gated" Kernel from the [Fedora CoreOS stable stream](https://www.fedoraproject.org/coreos/download/?stream=stable&arch=aarch64)
- Google Chrome RPM installed and set as default browser
- Clocks set to AM/PM view with Weekday Display
- Curated selection of Flatpak apps installed automatically
- Single click to open items in Nautilus
- Nautilus icons [match accent
  color](https://extensions.gnome.org/extension/7535/accent-directories/)
- [System monitor applet](https://github.com/mgalgs/gnome-shell-system-monitor-next-applet) in
  top panel next to Gnome system menu
- [DeskChanger](https://github.com/BigE/desk-changer/) wallpaper manager
- [Weather applet](https://gitlab.gnome.org/somepaulo/weather-or-not)
- Use smaller icons in Nautilus icon view
- Sort directories first in Nautilus and GTK file choosers
- Dark styles enabled by default
- [System76 wallpaper collection](https://system76.com/merch/desktop-wallpapers)
- [Framework 12](https://frame.work/laptop12) wallpapers
- Visual Studio Code RPM installed
- Libvirt virtualization stack installed
- Docker CE installed with rootful Docker disabled
- Dash-to-Dock enabled by default, skipping Overview on login
- Appindicators enabled by default
- Logo Menu enabled by default, like Bluefin
- Windows have minimize and maximize buttons (like Ubuntu and Bluefin)
- Additional packages (e.g. Firewall GUI, rclone/restic, Universal Blue enhancements)
- ``ujust`` scripts from Universal Blue images
- ``<CTRL><ALT>t`` opens a terminal  

## Production To-Do List

- [X] **Enable Image Signing** (Recommended)
  - Provides cryptographic verification of your images
  - Prevents tampering and ensures authenticity
  - See "Optional: Enable Image Signing" section above for setup instructions
  - Status: **Eanabled by default** to allow immediate testing

- [ ] **Enable SBOM Attestation** (Recommended)
  - Generates Software Bill of Materials for supply chain security
  - Provides transparency about what's in your image
  - Requires image signing to be enabled first
  - To enable:
    1. First complete image signing setup above
    2. Edit `.github/workflows/build.yml`
    3. Find the "OPTIONAL: SBOM Attestation" section around line 232
    4. Uncomment the "Add SBOM Attestation" step
    5. Commit and push
  - Status: **Disabled by default** (requires signing first)

- [X] **Enable Image Rechunking** (Recommended)
  - Optimizes bootc image layers for better update performance
  - Reduces update sizes by 5-10x
  - Improves download resumability with evenly sized layers
  - To enable:
    1. Edit `.github/workflows/build.yml`
    2. Find the "Build Image" step
    3. Add a rechunk step after the build (see example below)
  - Status: **enabled by default** (optional optimization)
- [ ] **Enable Production Branch & Image Builds**
  - Follow pattern from Bluefin LTS:
    - ``testing`` tag on ``main`` branch
    - ``production`` tag on ``production`` branch
    - Push changes from ``main`` to ``production``
  - Need to figure out:
    - How to enable building with a tag other than the ``DEFAULT_TAG``


## Detailed Guides

(Note: these need to be adusted from the tempalate)
- [Homebrew/Brewfiles](custom/brew/README.md) - Runtime package management
- [Flatpak Preinstall](custom/flatpaks/README.md) - GUI application setup
- [ujust Commands](custom/ujust/README.md) - User convenience commands
- [Build Scripts](build/README.md) - Build-time customization

