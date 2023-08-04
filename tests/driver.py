import numpy as np
from eos_nuclear import NuclearEOS, EOSVariable, EOSMode

#
# Reproduce the results of driver.F90 in EOSDriver
#

table="SFHo.h5"
neos = NuclearEOS(table)

var = EOSVariable()
var.xrho = 10.0**14.74994
var.xtemp = 63.0
var.xye = 0.2660725

mode = EOSMode()

var = neos.nuc_eos_short(var,mode=1)
print("###########################################")
print( "Short EOS ---------------------------------")
print(var.xrho,var.xtemp,var.xye)
print(var.xenr,var.xprs,var.xent,np.sqrt(var.xcs2))
print(var.xdedt,var.xdpdrhoe,var.xdpderho)
var = neos.nuc_eos_full(var,mode=mode.RHOT)
print("###########################################")
print("Full EOS ----------------------------------")
print(var.xrho,var.xtemp,var.xye)
print(var.xenr,var.xprs,var.xent,np.sqrt(var.xcs2))
print(var.xdedt,var.xdpdrhoe,var.xdpderho)
print(var.xabar,var.xzbar)
print(var.xxa,var.xxh,var.xxn,var.xxp)
print(var.xmu_e,var.xmu_p,var.xmu_n,var.xmuhat)

var.xtemp = 2.0*var.xtemp
var = neos.nuc_eos_full(var,mode=mode.RHOE)
print("###########################################")
print("Full EOS ----------------------------------")
print(var.xrho,var.xtemp,var.xye)
print(var.xenr,var.xprs,var.xent,np.sqrt(var.xcs2))
print(var.xdedt,var.xdpdrhoe,var.xdpderho)
print(var.xabar,var.xzbar)
print(var.xxa,var.xxh,var.xxn,var.xxp)
print(var.xmu_e,var.xmu_p,var.xmu_n,var.xmuhat)
print("###########################################")


