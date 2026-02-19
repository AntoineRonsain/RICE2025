import os
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
from pathlib import Path

from tools.tools import read_uncerainties_results
from tools.analysis_tools import plot_param_for_region

# --- CONFIGURATION ---
YEARS_N = 80
START_YEAR = 2020
TIME_STEPS = np.array([START_YEAR + i * 5 for i in range(YEARS_N)])
PLOT_LIMIT = 40  # Jusqu'en 2200

# Variables
VAR_DAM = "Marginal Cost of Damages (Shadow Price)"
VAR_ABAT = "Marginal Cost of Abatement (Shadow Price)"


def plot_sign_structure_grid(data_dict):
    """
    Trace une grille 4x3 :
    1. MAC (Non-reoptimized)
    2. MDC (Non-reoptimized)
    3. Net (Non-reoptimized)
    4. Delta Net (Non-reoptimized - Re-optimized)
       -> Signe (+) = Incitation à investir car le Net subi est pire que l'optimisé.
    """
    damage_levels = ["Low", "Medium", "Strong"]
    col_titles = ["Low Damage", "Medium Damage", "High Damage"]

    # Mise à jour des labels pour la sémantique Re-optimized / Non-reoptimized
    row_labels = [
        r"$\bf{MAC}$" + "\n(Non-reopt)",
        r"$\bf{MDC}$" + "\n(Non-reopt)",
        r"$\bf{Net}$" + "\n(Non-reopt)",
        r"$\bf{\Delta Net}$" + "\n(Re-opt. - Non-reopt.)"
    ]

    damage_key_map = {
        "Low": "Low Damage",
        "Medium": "Medium Damage",
        "Strong": "High Damage"
    }

    mpl.rc('xtick', labelsize=15)
    mpl.rc('ytick', labelsize=15)

    # Filtrage des régions
    sample_key = damage_key_map["Medium"]
    sample_data = data_dict[sample_key]['Re-optimized']
    regions_list = [r for r in sample_data.keys() if r != 'World' and 'asia' not in r.lower()]
    regions_list.sort()

    plot_params = plot_param_for_region(regions_list)

    OFFSET_STEP = 0.15
    fig, axs = plt.subplots(4, 3, figsize=(18, 16), sharex=True, sharey=True)

    global_handles, global_labels = [], []

    for col_idx, dmg in enumerate(damage_levels):
        key = damage_key_map[dmg]

        axs[0, col_idx].set_title(col_titles[col_idx], fontsize=16, weight='bold', pad=20)

        data_reopt = data_dict[key]['Re-optimized']
        data_nonreopt = data_dict[key]['Non-reoptimized']

        for idx, region in enumerate(regions_list):

            # --- DATA RE-OPTIMIZED (Base) ---
            mac_re = np.array(data_reopt[region][VAR_ABAT])[:PLOT_LIMIT]
            mcd_re = np.array(data_reopt[region][VAR_DAM])[:PLOT_LIMIT]
            net_re = mcd_re - mac_re

            # --- DATA NON-REOPTIMIZED (Subi) ---
            mac_non = np.array(data_nonreopt[region][VAR_ABAT])[:PLOT_LIMIT]
            mcd_non = np.array(data_nonreopt[region][VAR_DAM])[:PLOT_LIMIT]
            net_non = mcd_non - mac_non

            # Delta Net = Net(Re-opt) - Net(Non-reopt)
            diff_val = net_re - net_non

            def to_sign_offset(arr, i):
                signs = np.sign(arr)
                signs[np.abs(arr) < 1e-9] = 0
                return signs * (1 + (i * OFFSET_STEP))

            y_mac = to_sign_offset(mac_re, idx)
            y_mcd = to_sign_offset(mcd_re, idx)
            y_net = to_sign_offset(net_re, idx)
            y_diff_sce = to_sign_offset(diff_val, idx)

            color = plot_params[region]['color']
            style = plot_params[region]['style']
            lw = 2.5

            l1, = axs[0, col_idx].plot(TIME_STEPS[:PLOT_LIMIT], y_mac,
                                       color=color, linestyle=style, linewidth=lw, label=region)
            axs[1, col_idx].plot(TIME_STEPS[:PLOT_LIMIT], y_mcd,
                                 color=color, linestyle=style, linewidth=lw)
            axs[2, col_idx].plot(TIME_STEPS[:PLOT_LIMIT], y_net,
                                 color=color, linestyle=style, linewidth=lw)
            axs[3, col_idx].plot(TIME_STEPS[:PLOT_LIMIT], y_diff_sce,
                                 color=color, linestyle=style, linewidth=lw)

            if col_idx == 0:
                global_handles.append(l1)
                global_labels.append(region)

        for row in range(4):
            ax = axs[row, col_idx]
            max_limit = 1 + (len(regions_list) * OFFSET_STEP) + 0.5
            ax.set_ylim(-max_limit, max_limit)
            ax.axhspan(0, max_limit, color='green', alpha=0.07)
            ax.axhspan(-max_limit, 0, color='red', alpha=0.07)
            ax.axhline(0, color='black', linewidth=2, alpha=0.8, zorder=10)
            ax.set_yticks([])

            if col_idx == 0:
                ax.text(-0.02, 0.75, "(+)", transform=ax.transAxes, color='green', weight='bold', ha='right')
                ax.text(-0.02, 0.25, "(-)", transform=ax.transAxes, color='red', weight='bold', ha='right')

    for row_idx in range(4):
        axs[row_idx, 0].set_ylabel(row_labels[row_idx], fontsize=15, weight='bold', labelpad=25)

    for col_idx in range(3):
        axs[3, col_idx].set_xlabel("Year", fontsize=15)

    unique_handles, unique_labels = [], []
    seen = set()
    for h, l in zip(global_handles, global_labels):
        if l not in seen:
            unique_handles.append(h)
            unique_labels.append(l)
            seen.add(l)


    fig.legend(
        unique_handles,
        unique_labels,
        loc='center left',
        bbox_to_anchor=(0.01, 0.5),
        ncol=1,
        title=r"$\bf{Regions}$",
        fontsize=14,
        frameon=True,
        shadow=True
    )

    fig.suptitle("Sign Analysis: Incentives for Strategic Re-optimization", fontsize=22, weight='bold', y=0.96)

    plt.tight_layout()
    plt.subplots_adjust(top=0.90, bottom=0.08, left=0.18, right=0.95)
    plt.show()


def plot_value_structure_grid(data_dict):
    """
    Trace une grille 4x3 affichant les VALEURS réelles des indicateurs.
    Rangées : MAC, MDC, Net, Delta Net.
    Colonnes : Low, Medium, High Damage.
    """
    damage_levels = ["Low", "Medium", "Strong"]
    col_titles = ["Low Damage", "Medium Damage", "High Damage"]

    row_labels = [
        r"$\bf{MAC}$" + "\n(Non-reopt)",
        r"$\bf{MDC}$" + "\n(Non-reopt)",
        r"$\bf{Net}$" + "\n(Non-reopt)",
        r"$\bf{\Delta Net}$" + "\n(Re-opt. - Non-reopt.)"
    ]

    damage_key_map = {"Low": "Low Damage", "Medium": "Medium Damage", "Strong": "High Damage"}

    # Filtrage des régions
    sample_key = damage_key_map["Medium"]
    sample_data = data_dict[sample_key]['Re-optimized']
    regions_list = [r for r in sample_data.keys() if r != 'World' and 'asia' not in r.lower()]
    regions_list.sort()
    plot_params = plot_param_for_region(regions_list)

    # sharey='row' permet de comparer les niveaux de dommages (colonnes) à échelle égale par indicateur
    fig, axs = plt.subplots(4, 3, figsize=(18, 16), sharex=True, sharey='row')

    global_handles, global_labels = [], []

    for col_idx, dmg in enumerate(damage_levels):
        key = damage_key_map[dmg]
        axs[0, col_idx].set_title(col_titles[col_idx], fontsize=16, weight='bold', pad=20)

        data_reopt = data_dict[key]['Re-optimized']
        data_nonreopt = data_dict[key]['Non-reoptimized']

        for idx, region in enumerate(regions_list):
            if region not in data_reopt or region not in data_nonreopt:
                continue

            # --- CALCUL DES VALEURS RÉELLES ---
            # Re-optimized
            mac_re = np.array(data_reopt[region][VAR_ABAT])[:PLOT_LIMIT]
            mcd_re = np.array(data_reopt[region][VAR_DAM])[:PLOT_LIMIT]
            net_re = mcd_re - mac_re

            # Non-reoptimized
            mac_non = np.array(data_nonreopt[region][VAR_ABAT])[:PLOT_LIMIT]
            mcd_non = np.array(data_nonreopt[region][VAR_DAM])[:PLOT_LIMIT]
            net_non = mcd_non - mac_non

            # Delta Net =  Net(Re-opt) - Net(Non-reopt)
            diff_val = net_re - net_non

            color = plot_params[region]['color']
            style = plot_params[region]['style']
            lw = 2.0

            # Plotting
            time_axis = TIME_STEPS[:PLOT_LIMIT]

            # Row 0: MAC (on montre le non-reoptimisé pour être cohérent avec ton texte)
            l1, = axs[0, col_idx].plot(time_axis, mac_non, color=color, linestyle=style, linewidth=lw, label=region)
            # Row 1: MDC
            axs[1, col_idx].plot(time_axis, mcd_non, color=color, linestyle=style, linewidth=lw)
            # Row 2: NET
            axs[2, col_idx].plot(time_axis, net_non, color=color, linestyle=style, linewidth=lw)
            # Row 3: DELTA NET (L'incitation stratégique)
            axs[3, col_idx].plot(time_axis, diff_val, color=color, linestyle=style, linewidth=lw)

            if col_idx == 0:
                global_handles.append(l1)
                global_labels.append(region)

    # --- FORMATTAGE FINAL ---
    for row in range(4):
        for col in range(3):
            ax = axs[row, col]
            ax.axhline(0, color='black', linewidth=1.5, alpha=0.5, zorder=1)
            ax.grid(True, linestyle='--', alpha=0.3)

            # Optionnel : colorer légèrement le fond pour rappeler le signe
            # mais de façon plus subtile que dans la version "signes"
            if row < 3:  # Pour MAC, MDC, NET : le négatif est la norme
                ax.fill_between(TIME_STEPS[:PLOT_LIMIT], 0, ax.get_ylim()[0], color='red', alpha=0.03)
            else:  # Pour Delta Net : le positif est l'incitation
                ax.fill_between(TIME_STEPS[:PLOT_LIMIT], 0, ax.get_ylim()[1], color='green', alpha=0.03)

    for row_idx in range(4):
        axs[row_idx, 0].set_ylabel(row_labels[row_idx], fontsize=12, weight='bold')

    fig.legend(global_handles[:len(regions_list)], global_labels[:len(regions_list)],
               loc='lower center', bbox_to_anchor=(0.5, 0.02), ncol=6)

    fig.suptitle("Quantitative Analysis: Marginal Costs", fontsize=20, weight='bold', y=0.97)
    plt.tight_layout()
    plt.subplots_adjust(top=0.92, bottom=0.12)
    plt.show()

if __name__ == "__main__":

    BASE_DIR = Path(__file__).resolve().parents[1]
    OUTPUTS_DIR = BASE_DIR / "outputs"


    def load_output(filename):
        return read_uncerainties_results(os.path.join(OUTPUTS_DIR, filename))


    # Chargement d_ (Standards)
    d_nash = load_output("rice2023_nash.csv")
    d_q_nash = load_output("rice2023_nash_quad.csv")


    BASE_DIR = Path(__file__).resolve().parents[2]
    SPATIAL_DIR = BASE_DIR.parent / "spatial_consistency/outputs"

    def load_spatial(filename):
        return read_uncerainties_results(os.path.join(SPATIAL_DIR, filename))

    d10_nash = load_spatial("rice2023_nash_10asia.csv")
    d10_q_nash = load_spatial("rice2023_nash_quad_10asia.csv")


    # Mapping sémantique des données
    data_dict = {
        'Low Damage': {
            'Re-optimized': d10_q_nash.get('Low Damage', {}),
            'Non-reoptimized':  d_q_nash.get('Low Damage', {})
        },
        'Medium Damage': {
            'Re-optimized': d10_nash.get('Medium Damage', {}),
            'Non-reoptimized': d_nash.get('Medium Damage', {})
        },
        'High Damage': {
            'Re-optimized': d10_nash.get('High Damage', {}),
            'Non-reoptimized': d_nash.get('High Damage', {})
        }
    }

    plot_sign_structure_grid(data_dict)
    plot_value_structure_grid(data_dict)