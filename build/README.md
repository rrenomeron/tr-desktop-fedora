# Build Scripts

This directory contains the scripts that run the majority of the image build process.

## How It Works

The build is controlled by the ``build.sh``.  You'll need to edit it to include the reusable scripts
from ``tr-osforge`` you'll want to use by adding the names of the scripts (sans the ``.sh`` suffix) to the
``OSFORGE_SCRIPTS_TO_USE`` array variable in the script.

## Included Scripts

- ``build.sh`` - Controller script for the build process.
- ``custom.sh`` - Sets up the Flatpaks, Brewfiles, and ``ujust`` scripts that are included on your image.
- ``image-overrides.sh`` - Anything that is specific to this particular image that can't be shared in the ``tr-osforge`` repository.

## How To Make Changes to the Scripts

**Make it Reusable when Possible.** Generally, if what you want to add might be useful for one
of the other images (particularly the desktops), you will want to edit or add to the reusuable
scripts in the ``tr-osforge`` submodule.

**Avoid adding new scripts in this project.** Unless what you're adding is very complicated and
is not reusable in another image, prefer editing ``image-overrides.sh`` over adding a new
script and editing ``build.sh`` to run it.

**Managing the Submodule.** When you make a change to a file in the submodule, you will need to
make two separate commits:
- A commit in the submodule itself
- A commit _of_ the submodule in the project -- this will update the version of the submodule
  that the project will use.

### Best Practices

- **Use descriptive names**: `20-nvidia-drivers.sh` is better than `20-stuff.sh`
- **One purpose per script**: Easier to debug and maintain
- **Clean up after yourself**: Remove temporary files and disable temporary repos
- **Test incrementally**: Add one script at a time and test builds
- **Comment your code**: Future you will thank present you

## Notes

- Scripts run as root during build
- Build context is available at `/ctx`
- Use dnf5 for package management (not dnf or yum)
- Always use `-y` flag for non-interactive installs
