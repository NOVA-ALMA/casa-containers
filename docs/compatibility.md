# Compatibility

This page summarises the operating system and CASA version compatibility for
the images provided by this repository.

## General CASA

| CASA version | rh8 (Rocky Linux 8) | rh9 (Rocky Linux 9) | Python |
|---|:---:|:---:|---|
| 6.7.3 | ✅ | ✅ | 3.12 |
| 6.6.5 | ✅ | ✅ | 3.8 |

## ALMA Pipeline CASA

| Pipeline version | rh8 (Rocky Linux 8) | rh9 (Rocky Linux 9) | Python |
|---|:---:|:---:|---|
| 6.6.6-18 | ✅ | ❌ | 3.8 |

> ALMA pipeline images are officially supported on RHEL 8 / Rocky Linux 8 only.

## Base Images

| Image tag | Base OS | Notes |
|---|---|---|
| `casa-base:rh8` | Rocky Linux 8 | Common dependencies |
| `casa-base:rh9` | Rocky Linux 9 | Common dependencies |

## Notes

- CASA 6.7.x moved to Python 3.12; earlier 6.x releases use Python 3.8.
- macOS containers are not supported.  See `images/casa/base/mac/README.md`.
- See [`metadata/versions.yaml`](../metadata/versions.yaml) for the canonical
  list of tracked versions.
