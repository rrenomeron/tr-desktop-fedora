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
COPY --from=ghcr.io/projectbluefin/common:latest@sha256:4c44f1c0d672afe8eaa27ad149315e80c78b53774e31111abad5df0139b0de89 /system_files /oci/common
# This is the kernel from CoreOS
COPY --from=ghcr.io/ublue-os/akmods:coreos-stable-44-x86_64@sha256:7cf33520610e7820d5f4585f01f21f90bfae00303c50419790afa0ce43bec083 / /oci/akmods
# This is brew
COPY --from=ghcr.io/ublue-os/brew:latest@sha256:c201bc801e4828849e8e36c4adcb5c0f38d35ac3ff9546a0ecab0fd2beabf51f /system_files /oci/brew

# Copy from submodule.  We put it under /oci for convenience
COPY tr-osforge/reusable_scripting /oci/tr-osforge

# Base Image stage
# Renovatebot will happily update the Fedora version if you specify a number, which we don't want, since
# the ublue main image will produce beta images before the actual release.
# 
# The convention for ublue-main is "latest" for current Fedora, and "gts" for Fedora-1
FROM ghcr.io/ublue-os/silverblue-main:44@sha256:105c9ed455a5bbb43127c17cbb3a7cfe926f1df7a8d89327d6c5f152e14c7d58

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
## NOTE: the --skip var-tmpfiles is due to a weird problem involving an unexpected error
##  See https://github.com/rrenomeron/tr-desktop-fedora/actions/runs/25212412017/job/73925606106
RUN bootc container lint 
