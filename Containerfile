###############################################################################
# PROJECT NAME CONFIGURATION
###############################################################################
# Name: silverblue-tr-finpilot
#
# IMPORTANT: Change "silverblue-tr-finpilot" above to your desired project name.
# This name should be used consistently throughout the repository in:
#   - Justfile: export image_name := env("IMAGE_NAME", "your-name-here")
#   - README.md: # your-name-here (title)
#   - artifacthub-repo.yml: repositoryID: your-name-here
#   - custom/ujust/README.md: localhost/your-name-here:stable (in bootc switch example)
#
# The project name defined here is the single source of truth for your
# custom image's identity. When changing it, update all references above
# to maintain consistency.
###############################################################################

###############################################################################
# MULTI-STAGE BUILD ARCHITECTURE
###############################################################################
# This Containerfile follows the Bluefin architecture pattern as implemented in
# @projectbluefin/distroless. The architecture layers OCI containers together:
#
# 1. Context Stage (ctx) - Combines resources from:
#    - Local build scripts and custom files
#    - @projectbluefin/common - Desktop configuration shared with Aurora 
#    - @ublue-os/brew - Homebrew integration
#
# 2. Base Image Options:
#    - `ghcr.io/ublue-os/silverblue-main:latest` (Fedora and GNOME)
#    - `ghcr.io/ublue-os/base-main:latest` (Fedora and no desktop 
#    - `quay.io/centos-bootc/centos-bootc:stream10 (CentOS-based)` 
#
# See: https://docs.projectbluefin.io/contributing/ for architecture diagram
###############################################################################

# Context stage - combine local and imported OCI container resources
FROM scratch AS ctx

COPY build /build
COPY custom /custom
COPY system_files /system_files
# Copy from OCI containers to distinct subdirectories to avoid conflicts
# Note: Renovate can automatically update these :latest tags to SHA-256 digests for reproducibility
COPY --from=ghcr.io/projectbluefin/common:latest@sha256:9409d0c08bf76bdfef52812db61a68453b20b23b52042e810a447ada3c72c9c1 /system_files /oci/common
COPY --from=ghcr.io/ublue-os/brew:latest@sha256:d10f9b3117be2d2ca60cd3ae5e21ceb0317898d637b40a8291d9b913b454f095 /system_files /oci/brew
COPY --from=ghcr.io/ublue-os/akmods:coreos-stable-43@sha256:69977179fcb9fa59b1f0b025bd4cb209e2158bed54cdfb306609067abc102960 / /oci/akmods
# Copy from submodule.  We put it under /oci for convenience
COPY tr-osforge/reusable_scripting /oci/tr-osforge

# Renovatebot will happily update the Fedora version if you specify a number, which we don't want, since
# the ublue main image will produce beta images before the actual release.
# 
# The convention for ublue-main is "latest" for current Fedora, and "gts" for Fedora-1
FROM ghcr.io/ublue-os/silverblue-main:latest@sha256:c6f7b0d76b5c9411334cffe788c1eef1540c0f8c32c35098d8fb4d6d1900977c

ARG IMAGE_NAME
ARG TAG
## Alternative base images, no desktop included (uncomment to use):
# FROM ghcr.io/ublue-os/base-main:latest    
# FROM quay.io/centos-bootc/centos-bootc:stream10

## Alternative GNOME OS base image (uncomment to use):
# FROM quay.io/gnome_infrastructure/gnome-build-meta:gnomeos-nightly

### /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

# Need to do this in a separate RUN instruction because
# Kernel installation needs /tmp to be on the image,
# Not a bind mount elsewhere
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
/ctx/oci/tr-osforge/build/akmods-kernel.sh
### MODIFICATIONS

# Note: Building the image this way results in "one big layer", even with rechunking,
# which is very problematic.  So for now we'll run each script in its own RUN
# instruction, which the rechunker seems to like better.
#
# Revisit this when we find a better solution to rechunking

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \  
    --mount=type=bind,from=ghcr.io/blue-build/modules:latest,src=/modules,dst=/tmp/modules,rw \
    --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:latest,src=/scripts/,dst=/tmp/scripts/ \
    /ctx/build/build.sh

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/oci/tr-osforge/build/flatpak-substiution-removals.sh

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \  
#     --mount=type=bind,from=ghcr.io/blue-build/modules:latest,src=/modules,dst=/tmp/modules,rw \
#     --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:latest,src=/scripts/,dst=/tmp/scripts/ \
#     /ctx/oci/tr-osforge/build/bluefin-parity.sh

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/oci/tr-osforge/build/tr-pki.sh

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \  
#     --mount=type=bind,from=ghcr.io/blue-build/modules:latest,src=/modules,dst=/tmp/modules,rw \
#     --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:latest,src=/scripts/,dst=/tmp/scripts/ \
#     /ctx/oci/tr-osforge/build/tr-ui.sh


# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/oci/tr-osforge/build/brew.sh 

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/oci/tr-osforge/build/google-chrome.sh 

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/oci/tr-osforge/build/vscode.sh 
    

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/oci/tr-osforge/build/cockpit.sh


# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/oci/tr-osforge/build/virtualization.sh 


# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/oci/tr-osforge/build/docker.sh

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/build/image-overrides.sh

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/build/custom.sh    
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
