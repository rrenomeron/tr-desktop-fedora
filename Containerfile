###############################################################################
# PROJECT NAME CONFIGURATION
###############################################################################
# Name: tr-desktop-fedora
#
# IMPORTANT: This name should be used consistently throughout the repository in:
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
#    - @ublue-os/akmods - Kernel and additional modules
#    - @ublue-os/brew - Homebrew integration
#    - @rrenomeron/tr-osforge - Shared build scripting
#
# 2. Base Image:
#    - `ghcr.io/ublue-os/silverblue-main:latest` (Fedora and GNOME)
# 
# 3. Customizations:
#    - see build/build.sh and custom/*
#     
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
COPY --from=ghcr.io/projectbluefin/common:latest@sha256:51a753b108b115196e01b8ee11462c1f3888500947ae9a43906d5596cc99f651 /system_files /oci/common
COPY --from=ghcr.io/ublue-os/brew:latest@sha256:893a916a675c7d22b1140b7766c6d03b601c231e1e6aefbc57434bc27f32279e /system_files /oci/brew
COPY --from=ghcr.io/ublue-os/akmods:coreos-stable-43@sha256:de1267996dc98b6ccbbb6790f27cddf9faaba0bf01a826743bb993d48c064b6a / /oci/akmods
# Copy from submodule.  We put it under /oci for convenience
COPY tr-osforge/reusable_scripting /oci/tr-osforge

# Base Image stage
# Renovatebot will happily update the Fedora version if you specify a number, which we don't want, since
# the ublue main image will produce beta images before the actual release.
# 
# The convention for ublue-main is "latest" for current Fedora, and "gts" for Fedora-1
FROM ghcr.io/ublue-os/silverblue-main:latest@sha256:035f9ff9fc5f7a83845b2117287d20ed658659a27d3032864c89eb432a87ce9e

ARG IMAGE_NAME
ARG TAG

# FEDORA CoreOS KERNEL SWAP
# Need to do this in a separate RUN instruction because
# Kernel installation needs /tmp to be on the image,
# Not a bind mount elsewhere
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
/ctx/oci/tr-osforge/build/akmods-kernel.sh

### OTHER MODIFICATIONS
# 
# Most of the build is delegated to the build scripts
# See build/build.sh for more details.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \  
    --mount=type=bind,from=ghcr.io/blue-build/modules:latest,src=/modules,dst=/tmp/modules,rw \
    --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:latest,src=/scripts/,dst=/tmp/scripts/ \
    /ctx/build/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
