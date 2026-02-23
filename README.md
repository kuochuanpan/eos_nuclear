# eos_nuclear

A Python wrapper for the nuclear equation of state (EOS) table driver from [stellarcollapse.org](http://stellarcollapse.org).

## Prerequisites

- Python >= 3.9
- `gfortran`
- HDF5 (with Fortran bindings, discoverable via `pkg-config`)
- `numpy >= 1.26`

### macOS (Homebrew)

```bash
brew install gcc hdf5
```

### Ubuntu / Debian

```bash
sudo apt install gfortran libhdf5-dev pkg-config
```

### HPC Clusters

Load the appropriate modules, e.g.:

```bash
module load gcc openmpi hdf5
```

Make sure `pkg-config` can find HDF5:

```bash
pkg-config --libs hdf5_fortran   # should print -lhdf5_fortran -lhdf5 ...
```

If HDF5 is not in the default pkg-config path, set:

```bash
export PKG_CONFIG_PATH=/path/to/hdf5/lib/pkgconfig:$PKG_CONFIG_PATH
```

## Installation

### From GitHub (recommended)

```bash
pip install git+https://github.com/kuochuanpan/eos_nuclear.git
```

### From a local clone

```bash
git clone https://github.com/kuochuanpan/eos_nuclear.git
cd eos_nuclear
pip install .
```

### Editable install (for development)

```bash
pip install --no-build-isolation -e .
```

## Uninstall

```bash
pip uninstall eos_nuclear
```

## Usage

Download an EOS table in HDF5 format from [stellarcollapse.org](https://stellarcollapse.org/equationofstate.html).

```python
import numpy as np
from eos_nuclear import NuclearEOS, EOSVariable, EOSMode

# Load EOS table
table = "SFHo.h5"
neos = NuclearEOS(table)

# Set thermodynamic state
var = EOSVariable()
var.xrho = 10.0**14.74994   # density [g/cm^3]
var.xtemp = 63.0             # temperature [MeV]
var.xye = 0.2660725          # electron fraction

mode = EOSMode()

# Short EOS call (basic thermodynamic quantities)
var = neos.nuc_eos_short(var, mode=mode.RHOT)
print(f"P = {var.xprs:.6e} dyne/cm^2")
print(f"s = {var.xent:.6f} kB/baryon")
print(f"cs = {np.sqrt(var.xcs2):.6e} cm/s")

# Full EOS call (includes composition and chemical potentials)
var = neos.nuc_eos_full(var, mode=mode.RHOT)
print(f"Xn = {var.xxn:.6f}, Xp = {var.xxp:.6f}")
print(f"mu_e = {var.xmu_e:.3f} MeV")
```

### EOS Modes

| Mode | Description |
|------|-------------|
| `EOSMode.RHOT` | Input: density, temperature, Ye |
| `EOSMode.RHOE` | Input: density, energy, Ye (solve for temperature) |
| `EOSMode.RHOS` | Input: density, entropy, Ye (solve for temperature) |
| `EOSMode.PT`   | Input: pressure, temperature, Ye (solve for density) |

### Convenience Methods

```python
# From density [g/cm³], temperature [K], and Ye
var = neos.getEOSfromRhoTempYe(rho=1e12, temp=1e10, ye=0.3)

# From density, entropy [kB/baryon], and Ye
var = neos.getEOSfromRhoEntrYe(rho=1e12, entr=5.0, ye=0.3)

# From density, energy [erg/g], and Ye
var = neos.getEOSfromRhoEnerYe(rho=1e12, ener=1e20, ye=0.3)
```

See `tests/driver.py` for a complete example.

## Build System

This package uses [meson-python](https://meson-python.readthedocs.io/) to compile the Fortran EOS routines via `f2py` at install time. No manual compilation or `make` steps required — `pip install` handles everything.

## Acknowledgment

The Fortran source codes are taken from [stellarcollapse.org](http://stellarcollapse.org) and can be downloaded [here](https://stellarcollapse.org/equationofstate.html).

If you use this Python wrapper, please cite:

> E. O'Connor and C. D. Ott, *A New Spherically-Symmetric General Relativistic Hydrodynamics Code for Stellar Collapse to Neutron Stars and Black Holes*, Class. Quant. Grav., **27**, 114103, 2010.

and the original authors of the EOS table you use.
