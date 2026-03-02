import sys
import json
import numpy as np
from scipy.optimize import fsolve


class ReactorConfig():
    def __init__(self):
        self.reactor = None
        self.num_reactors = None


class Reaction():
    def __init__(self):
        self.rctr_vol = None        # L
        self.mol_flow_rate_A = None # mol/s
        self.conversion = None
        self.reaction_rate = None   # mol/L·s
        self.time = None            # s


def CSTR_residual(X, V, F_A0, C_A0, n, k):
    # Concentration of A in terms of conversion
    CA = C_A0 * (1 - X)
    # Reaction rate  -rA = k * CA^n
    rxn_rate = k * CA**n
    # CSTR design equation: F_A0 * X = -rA * V  →  residual = 0
    return -X + (V * rxn_rate / F_A0)


def solve_cstr(params):
    # --- unpack params from JSON ---
    V    = params["V"]      # reactor volume, L
    Ca0  = params["Ca0"]    # inlet concentration, mol/L
    v0   = params["v0"]     # volumetric flow rate, L/s
    k    = params["k"]      # rate constant
    n    = params.get("order", 1)  # reaction order, default 1

    F_A0 = Ca0 * v0         # molar flow rate of A, mol/s

    # --- solve for conversion ---
    X_guess = 0.5
    X_solution, info, ier, msg = fsolve(
        CSTR_residual,
        X_guess,
        args=(V, F_A0, Ca0, n, k),
        full_output=True
    )

    if ier != 1:
        return {"error": f"Solver did not converge: {msg}"}

    X = float(np.clip(X_solution[0], 0.0, 1.0))

    # --- populate Reaction object ---
    rxn = Reaction()
    rxn.rctr_vol        = V
    rxn.mol_flow_rate_A = F_A0
    rxn.conversion      = X
    rxn.reaction_rate   = float(k * (Ca0 * (1 - X))**n)
    rxn.time            = V / v0   # residence time τ

    # --- build result dict for display.lua ---
    return {
        "unit":               "CSTR",
        "conversion_X":       round(rxn.conversion, 4),
        "Ca_out_mol_L":       round(Ca0 * (1 - X), 4),
        "residence_time_s":   round(rxn.time, 4),
        "reactor_volume_L":   round(rxn.rctr_vol, 4),
        "reaction_rate":      round(rxn.reaction_rate, 4),
        "Ca0":                Ca0,
        "k":                  k,
    }


def main():
    # Ingest JSON from stdin (piped from init.lua)
    raw = sys.stdin.read()
    try:
        params = json.loads(raw)
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"Invalid JSON input: {e}"}))
        sys.exit(1)

    # Route to solver (only CSTR for now)
    unit = params.get("unit", "CSTR").upper()
    if unit == "CSTR":
        result = solve_cstr(params)
    else:
        result = {"error": f"Unit op '{unit}' not yet supported"}

    # Return JSON to stdout (read back by init.lua)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
