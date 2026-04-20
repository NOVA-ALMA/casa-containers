# casa-containers
Container builds for CASA, published to GitHub Container Registry.

## Image Types

Build images using `ci/scripts/build.sh`:

```
build.sh <type> <platform> [<version>] [<variant>]
```

| Type       | Description                                      | Example invocation                           |
|------------|--------------------------------------------------|----------------------------------------------|
| `base`     | Base OS image with CASA runtime dependencies     | `build.sh base rh8`                          |
| `general`  | CASA release installed from NRAO tar.gz          | `build.sh general rh8 6.7.3`                 |
| `pipeline` | CASA pipeline release (e.g. ALMA pipeline)       | `build.sh pipeline rh8 6.6.6-18 alma`        |
| `dev`      | CASA development/pre-release build from tar.xz   | `build.sh dev rh8 6.7.3-21`                  |

### `dev` image type

The `dev` type builds images that install CASA from pre-release tarballs following
the filename pattern:

```
casa-<X.Y.Z>-<build>-py<python>.el<os>.tar.xz
```

Tarballs are downloaded from `https://casa.nrao.edu/download/distro/casa/releaseprep`
by default. Set the `BASE_URL` environment variable inside the container build to
override this location.

**Supported versions / platforms:**

| Version     | Platform | Tarball                                  |
|-------------|----------|------------------------------------------|
| `6.7.3-21`  | `rh8`    | `casa-6.7.3-21-py3.12.el8.tar.xz`       |
| `6.7.3-21`  | `rh9`    | `casa-6.7.3-21-py3.12.el9.tar.xz`       |

**Examples:**

```bash
# Build for el8 (Red Hat / AlmaLinux / Rocky Linux 8)
build.sh dev rh8 6.7.3-21

# Build for el9 (Red Hat / AlmaLinux / Rocky Linux 9)
build.sh dev rh9 6.7.3-21
```

The resulting image is tagged as:

```
ghcr.io/nova-alma/casa-dev:<X.Y.Z>-<build>-<platform>
# e.g. ghcr.io/nova-alma/casa-dev:6.7.3-21-rh8
```
