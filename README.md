# eos_nuclear
A nuclear EoS python wrapper to use the Nuclear EOS driver from [http://stellarcollapse.org](http://stellarcollapse.org).

## PRE-REQUIREMENTS

* `python3`
* `numpy` (f2py is now included in `numpy`)
* `gfortran`
* `hdf5` 

## Installation

1. Edit the `make.inc` in `./eos_nuclear/src/make.inc`
2. Make sure you have FFLAGS ```-fPIC```
3. Compile the Fortran source codes by `make`
4. Generate the python module using `f2py`:

for example, 
```
f2py3 -m eospy -c eospy.F90 nuc_eos.a -I/cluster/software/hdf5-parallel/1.8.21/gcc--8.3.0/openmpi--3.1.4/include -L/cluster/software/hdf5-parallel/1.8.21/gcc--8.3.0/openmpi--3.1.4/lib -lhdf5 -lhdf5_fortran -lhdf5 -lz
```
5. Run 
```
python setup.py install
```

## Usage

Please see examples in `./tests`.
The EoS table can be downloaded from [stellarcollapse.org](https://stellarcollapse.org/equationofstate.html).

```
import numpy as np
import eos_nuclear as ne

#
# Reproduce the results of driver.F90 in EOSDriver
#

table="SFHo.h5"
neos = ne.NuclearEOS(table)

var = ne.EOSVariable()
var.xrho = 10.0**14.74994
var.xtemp = 63.0
var.xye = 0.2660725


var = neos.nuc_eos_short(var,mode=1)
print("###########################################")
print( "Short EOS ---------------------------------")
print(var.xrho,var.xtemp,var.xye)
print(var.xenr,var.xprs,var.xent,np.sqrt(var.xcs2))
print(var.xdedt,var.xdpdrhoe,var.xdpderho)
var = neos.nuc_eos_full(var,mode=ne.EOSMODE_RHOT)
print("###########################################")
print("Full EOS ----------------------------------")
print(var.xrho,var.xtemp,var.xye)
print(var.xenr,var.xprs,var.xent,np.sqrt(var.xcs2))
print(var.xdedt,var.xdpdrhoe,var.xdpderho)
print(var.xabar,var.xzbar)
print(var.xxa,var.xxh,var.xxn,var.xxp)
print(var.xmu_e,var.xmu_p,var.xmu_n,var.xmuhat)

var.xtemp = 2.0*var.xtemp
var = neos.nuc_eos_full(var,mode=ne.EOSMODE_RHOE)
print("###########################################")
print("Full EOS ----------------------------------")
print(var.xrho,var.xtemp,var.xye)
print(var.xenr,var.xprs,var.xent,np.sqrt(var.xcs2))
print(var.xdedt,var.xdpdrhoe,var.xdpderho)
print(var.xabar,var.xzbar)
print(var.xxa,var.xxh,var.xxn,var.xxp)
print(var.xmu_e,var.xmu_p,var.xmu_n,var.xmuhat)
print("###########################################")


```

## Acknowledgment 

The fortran source codes are taken from [http://stellarcollapse.org](http://stellarcollapse.org).
It can be downloaded from [here](https://stellarcollapse.org/equationofstate.html).

If you use this python wrapper, please make reference to Evan O’Connor and Christian D. Ott, A New Spherically-Symmetric General Relativistic Hydrodynamics Code for Stellar Collapse to Neutron Stars and Black Holes, Class. Quant. Grav., 27 114103, 2010, and, of course, the original authors of the EOS.
