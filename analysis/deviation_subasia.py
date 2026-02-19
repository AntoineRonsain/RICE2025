import os
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
from pathlib import Path
from tabulate import tabulate

from tools.tools import read_uncerainties_results
from tools.compute_st_dev import compute_norm_euclide

YEARS_N = 80
START_YEAR = 2020
TIME_STEPS = np.array([START_YEAR + i * 5 for i in range(YEARS_N)])


def get_emission_limit_curve(n_steps=90):
    """
    Constructs the physical upper bound curve for emission control rates (miu).

    Args:
        n_steps (int): Number of time steps.

    Returns:
        np.array: The upper limit curve.
    """
    miuup = np.ones(n_steps) * 0.05
    miuup[1] = 0.10

    limmiu2070 = 1.0
    limmiu2120 = 1.1
    delmiumax = 0.12

    for t in range(2, n_steps):
        if t <= 7:
            miuup[t] = delmiumax * t
        elif t <= 10:
            miuup[t] = 0.85 + 0.05 * (t - 7)
        elif t <= 19:
            miuup[t] = limmiu2070
        else:
            miuup[t] = limmiu2120
    return miuup


def compute_dispersion(mu_dict):
    """
    Computes the average Euclidean norm of dispersion across regions.

    Args:
        mu_dict (dict): Dictionary of emission control rates per region.

    Returns:
        float: The average dispersion value.
    """
    norm_euclide = compute_norm_euclide(mu_dict)
    values = list(norm_euclide.values())

    if not values:
        return 0.0

    return np.mean(values)


def plot_emission_comparison(data_dict, limit_curve):
    """
    Plots the comparison of emission control rates:
    Global Asia vs. Disaggregated Asia (ASIA0/Mean) + Physical Limit.

    Layout: 3 Rows (Damage levels) x 2 Columns (Coop vs Non-Coop).
    """
    rows_scenarios = ["Low", "Medium", "Strong"]
    cols_scenarios = ["Cooperative", "Non-Cooperative"]

    mpl.rc('xtick', labelsize=15)
    mpl.rc('ytick', labelsize=15)

    fig, axs = plt.subplots(3, 2, figsize=(14, 18), sharex=True, sharey=False)

    damage_key_map = {
        "Low": "Low Damage",
        "Medium": "Medium Damage",
        "Strong": "Strong Damage"
    }

    for i, damage_level in enumerate(rows_scenarios):
        for j, coop_mode in enumerate(cols_scenarios):
            ax = axs[i, j]

            full_key = f"{coop_mode} + {damage_key_map[damage_level]}"

            if full_key not in data_dict:
                print(f"Warning: Key '{full_key}' not found in data.")
                continue

            scenario_data = data_dict[full_key]

            ax.plot(TIME_STEPS, limit_curve, color="black", lw=3, label="Upper bound")

            # 2. Plot Global Asia (Blue solid)
            asia_1_series = scenario_data['1Asia'].get('ASIA', {}).get("Emissions control rate")
            if asia_1_series is not None:
                ax.plot(TIME_STEPS, asia_1_series[:YEARS_N],
                        color='blue', lw=2.5, label="Asia (Global Model)")

            asia_10_series = scenario_data['10Asia'].get('ASIA0', {}).get("Emissions control rate")
            if asia_10_series is not None:
                ax.plot(TIME_STEPS, asia_10_series[:YEARS_N],
                        color='blue', linestyle="--", lw=2.5, label="Asia (Disaggregated)")

            if i == 0:
                ax.set_title(coop_mode, fontsize=22, pad=20, weight='bold')

            if j == 0:
                ax.set_ylabel(f"{damage_level} Damages", fontsize=20, labelpad=20, weight='bold')

    handles, labels = axs[0, 0].get_legend_handles_labels()
    fig.legend(handles, labels, loc='upper center', bbox_to_anchor=(0.5, 1.0), ncol=3, fontsize=15)
    plt.tight_layout()
    plt.subplots_adjust(top=0.90)
    plt.show()


if __name__ == "__main__":
    BASE_DIR = Path(__file__).resolve().parents[1]
    OUTPUTS_DIR = BASE_DIR / "spatial_consistency/outputs"


    def load_data(filename):
        return read_uncerainties_results(os.path.join(OUTPUTS_DIR, filename))


    d_negishi = load_data("rice2023_negishi.csv")
    d10_negishi = load_data("rice2023_negishi_10asia.csv")
    d_q_negishi = load_data("rice2023_negishi_quad.csv")
    d10_q_negishi = load_data("rice2023_negishi_quad_10asia.csv")

    d_nash = load_data("rice2023_nash.csv")
    d10_nash = load_data("rice2023_nash_10asia.csv")
    d_q_nash = load_data("rice2023_nash_quad.csv")
    d10_q_nash = load_data("rice2023_nash_quad_10asia.csv")

    data_dict = {
        'Non-Cooperative + Low Damage': {
            '1Asia': d_q_nash['Low Damage'], '10Asia': d10_q_nash['Low Damage']},
        'Non-Cooperative + Medium Damage': {
            '1Asia': d_nash['Medium Damage'], '10Asia': d10_nash['Medium Damage']},
        'Non-Cooperative + Strong Damage': {
            '1Asia': d_nash['High Damage'], '10Asia': d10_nash['High Damage']},

        'Cooperative + Low Damage': {
            '1Asia': d_q_negishi['Low Damage'], '10Asia': d10_q_negishi['Low Damage']},
        'Cooperative + Medium Damage': {
            '1Asia': d_negishi['Medium Damage'], '10Asia': d10_negishi['Medium Damage']},
        'Cooperative + Strong Damage': {
            '1Asia': d_negishi['High Damage'], '10Asia': d10_negishi['High Damage']},
    }

    # 4. Compute and Print Dispersion Table
    dispersion_results = []
    for sce, content in data_dict.items():
        # Filter only ASIA sub-regions for dispersion calculation
        asia_subregions_data = {
            r: content['10Asia'][r]["Emissions control rate"][:YEARS_N]
            for r in content['10Asia'].keys() if "ASIA" in r
        }

        disp_val = compute_dispersion(asia_subregions_data)
        dispersion_results.append([sce, disp_val])

    print("\n--- Dispersion Results ---")
    print(tabulate(dispersion_results, headers=["Scenario", "Dispersion"], tablefmt="fancy_grid"))

    # 5. Plotting
    limit_curve = get_emission_limit_curve(YEARS_N)
    plot_emission_comparison(data_dict, limit_curve)