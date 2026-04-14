# Fedora Desktop Standard Operating Environment

This is my answer to the question "How Do You Fedora?", or my 
[standard operating environment](https://www.redhat.com/en/topics/management/what-is-an-soe),
or in less dorky terms, how I run [Fedora](https://fedoraproject.org) on my desktop and laptop computers.

This is a [bootable container image](https://developers.redhat.com/articles/2024/09/24/bootc-getting-started-bootable-containers),
which is an operating system delivered as an OCI container and is updated as a unit in the
background, with the updates applied on reboot.  At runtime, the files delivered this way are
immutable.  This has several advantages over traditional Linux systems that are composed of
indvidual packages (DEB or RPM), including:

- The core operating system can't be changed, accidentally or maliciously, at runtime
- Software that is not considered part of the "core" is isolated from the system either by
  running in a container via Podman or Docker, or via [Flatpak](https://flatpak.org) 
  or [Brew](https://brew.sh), and is updated independently, making it easier for applications to
  stay up-to-date, and lessening risks of breakage when upgrading to a new Fedora version
- The packages consisting of the core are assembled in a CI system on Github, which catches any
  RPM installation failures before they reach an actual computer, lessening the risk of a broken
  system.
- If an update breaks the core system, it is easy to roll back to the previous, known-good state
- Things that are always done to a stock Fedora/GNOME installation (e.g. changing default
  settings, installing multimedia packages that Fedora won't distribute and critical GNOME
  extensions) are "baked in" to the image, simplifying new device provisioning

**An Important Disclaimer**: While this image is available publicly, it is designed for the use
by me and my family and nobody else.  See the ``LICENSE`` in this repository, noting especially the Disclaimer
of Warranty.  If you're looking for an "image-based" Linux to try, I 
recommend checking out [Bluefin](https://projectbluefin.io) or [Bazzite](https://bazzite.gg).
Both have great community support.

## About This Image

This image consists of [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) with 
customizations from [Bluefin](https://projectbluefin.io) and [Universal Blue](https://universal-blue.org)
and my own personal preferences.

These are the important features of this image:

- "Gated" Kernel from the [Fedora CoreOS stable stream](https://www.fedoraproject.org/coreos/release-notes)
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


## Tags and Streams

There are two main "streams" for this image:

- **Testing Stream (``:testing`` tag)**: Updated at least daily.  This is built from the
  ``main`` branch
- **Production Stream (``:production`` tag)**: Updated weekly via promotion from testing stream,
  built weekly from the ``production`` branch.

When a new Fedora release is made, there may also be a ``:beta-$VERSION`` tag (e.g. ``beta-44``)
and corresponding branch to facilitate testing of the new release.

## Development and Maintenance Process

### Getting Started

Initialize the submodule and prepare it for editing:
```
just setup-submodule
git checkout main
```

### Working with the Build Scripts

See [build/README.md](build/README.md)

### Local Development and Testing

To test changes locally, do the following:
```
just build
# Copy the image to rootful storage so bootc can see it
podman image scp $USER@localhost:localhost/tr-desktop-fedora:localdev 

# If you aren't already running a locally built image
sudo bootc switch --transport containers-storage localhost/tr-desktop-fedora:localdev

# If you are running a prior version that was built locally:
sudo bootc update

```

### Routine Dependency Updates

These are handled by [Renovate](https://github.com/renovatebot/renovate), which runs
periodically as a Github Action.  It handles updates to the base image and other
dependent OCI images, as well as updates the submodule containing reusable scripting.

The updates arrive as pull requests, which are automerged into testing after checking
that they don't break the container build.  (But see #37.)

### Promotion to Production

On Saturday, assuming no issues with the testing stream, the week's changes are merged into
the ``production`` branch, from which a production build is then built.  Currently this is
a manual process, with plans to automate in the future (#36).

### Fedora Major Upgrades

Begin the process when:

- Fedora has released the new version and the CoreOS stable stream has moved to it
- The following GNOME extensions have been updated for the new version:
  - [system-monitor-next](https://extensions.gnome.org/extension/3010/system-monitor-next/)
  - [Accent Icons](https://extensions.gnome.org/extension/7535/accent-directories/)
  - [Weather or Not](https://extensions.gnome.org/extension/5660/weather-or-not/)
  - [DeskChanger](https://extensions.gnome.org/extension/1131/desk-changer/)
- There is no chatter in the Bluefin Discord or Github discussions about broken things in the
  latest Fedora

Begin with a new branch called ``beta-$VERSION``; update the CI workflow so that it will
build on a push to this branch (and also tag and push to GHCR).  Test for a while, making sure
to test:

- Desktop polish
- Running VMs

When the build is satisfactory (and it's plausible for it to be ready for production in 1 week
or less), land on the main branch via Pull Request and continue testing via the testing stream

### Other Changes

For small things, commit directly to ``main`` and the testing stream.  For larger things, do 
a feature branch and land by PR.

### Coding Standards

TBD