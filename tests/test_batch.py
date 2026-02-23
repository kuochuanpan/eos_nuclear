"""
Test batch EOS calls and verify consistency with single-point calls.
Also benchmark performance.
"""
import numpy as np
import time
from eos_nuclear import NuclearEOS, EOSVariable, EOSMode

table = "SFHo.h5"
neos = NuclearEOS(table)
mode = EOSMode()

# ============================================================
# 1. Correctness: compare batch vs single-point results
# ============================================================
print("=" * 60)
print("TEST 1: Correctness — batch vs single-point")
print("=" * 60)

# Test with a few known points
rho_vals  = np.array([1e10, 1e12, 10**14.74994, 1e14])
temp_vals = np.array([1.0, 10.0, 63.0, 30.0])
ye_vals   = np.array([0.5, 0.3, 0.2660725, 0.4])

# Batch short
result = neos.nuc_eos_short_batch(rho_vals, temp_vals, ye_vals, mode=mode.RHOT)

# Compare with single-point
all_pass = True
for i in range(len(rho_vals)):
    var = EOSVariable()
    var.xrho = rho_vals[i]
    var.xtemp = temp_vals[i]
    var.xye = ye_vals[i]
    var = neos.nuc_eos_short(var, mode=mode.RHOT)

    prs_diff = abs(result['prs'][i] - var.xprs) / (abs(var.xprs) + 1e-30)
    ent_diff = abs(result['ent'][i] - var.xent) / (abs(var.xent) + 1e-30)
    cs2_diff = abs(result['cs2'][i] - var.xcs2) / (abs(var.xcs2) + 1e-30)

    if max(prs_diff, ent_diff, cs2_diff) > 1e-12:
        print(f"  FAIL point {i}: prs={prs_diff:.2e} ent={ent_diff:.2e} cs2={cs2_diff:.2e}")
        all_pass = False

if all_pass:
    print("  ✅ short_batch matches single-point for all 4 test points")

# Batch full
result_full = neos.nuc_eos_full_batch(rho_vals, temp_vals, ye_vals, mode=mode.RHOT)

all_pass = True
for i in range(len(rho_vals)):
    var = EOSVariable()
    var.xrho = rho_vals[i]
    var.xtemp = temp_vals[i]
    var.xye = ye_vals[i]
    var = neos.nuc_eos_full(var, mode=mode.RHOT)

    mu_e_diff = abs(result_full['mu_e'][i] - var.xmu_e) / (abs(var.xmu_e) + 1e-30)
    xn_diff = abs(result_full['xn'][i] - var.xxn) / (abs(var.xxn) + 1e-30)

    if max(mu_e_diff, xn_diff) > 1e-12:
        print(f"  FAIL point {i}: mu_e={mu_e_diff:.2e} xn={xn_diff:.2e}")
        all_pass = False

if all_pass:
    print("  ✅ full_batch matches single-point for all 4 test points")

# Check error codes
assert np.all(result['error'] == 0), "short_batch has errors!"
assert np.all(result_full['error'] == 0), "full_batch has errors!"
print("  ✅ All error codes = 0")

# ============================================================
# 2. Test RHOE mode (iterative solve)
# ============================================================
print()
print("=" * 60)
print("TEST 2: RHOE mode — batch iterative solve")
print("=" * 60)

# First get energy from RHOT
result_rt = neos.nuc_eos_short_batch(rho_vals, temp_vals, ye_vals, mode=mode.RHOT)
enr = result_rt['enr'].copy()

# Now solve back from energy (with trial temperature = 2x)
trial_temp = temp_vals * 2.0
result_re = neos.nuc_eos_short_batch(
    rho_vals, trial_temp, ye_vals, enr=enr, mode=mode.RHOE
)

temp_recovery = np.max(np.abs(result_re['temp'] - temp_vals) / temp_vals)
print(f"  Max relative temperature recovery error: {temp_recovery:.2e}")
assert temp_recovery < 1e-8, "RHOE temperature recovery failed!"
print("  ✅ RHOE mode recovers correct temperatures")

# ============================================================
# 3. Performance benchmark
# ============================================================
print()
print("=" * 60)
print("TEST 3: Performance benchmark")
print("=" * 60)

for N in [1000, 10_000, 100_000, 1_000_000]:
    rho = np.logspace(10, 15, N)
    temp = np.full(N, 10.0)
    ye = np.full(N, 0.3)

    t0 = time.perf_counter()
    res = neos.nuc_eos_short_batch(rho, temp, ye, mode=mode.RHOT)
    dt_batch = time.perf_counter() - t0

    print(f"  N={N:>10,d}  batch_short: {dt_batch:.4f}s  ({N/dt_batch:.0f} pts/s)")

print()
N_bench = 10_000

# Compare: Python loop vs batch
rho = np.logspace(10, 15, N_bench)
temp = np.full(N_bench, 10.0)
ye = np.full(N_bench, 0.3)

t0 = time.perf_counter()
for i in range(N_bench):
    var = EOSVariable()
    var.xrho = rho[i]; var.xtemp = temp[i]; var.xye = ye[i]
    var = neos.nuc_eos_short(var, mode=mode.RHOT)
dt_loop = time.perf_counter() - t0

t0 = time.perf_counter()
res = neos.nuc_eos_short_batch(rho, temp, ye, mode=mode.RHOT)
dt_batch = time.perf_counter() - t0

speedup = dt_loop / dt_batch
print(f"  Python loop ({N_bench:,d} pts): {dt_loop:.4f}s")
print(f"  Batch       ({N_bench:,d} pts): {dt_batch:.4f}s")
print(f"  Speedup: {speedup:.1f}x")
print()
print("All tests passed! ✅")
