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
PLOT_LIMIT = 40

VAR_DAM = "Marginal Cost of Damages (Shadow Price)"
VAR_ABAT = "Marginal Cost of Abatement (Shadow Price)"


def plot_value_structure_grid(data_dict, save_path=None):
    """
    Trace une grille 4x3 avec une échelle SYMLOG forcée par ligne.
    L'échelle est logarithmique pour les grandes valeurs et linéaire autour de zéro.
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

    # Extraction des régions
    sample_key = damage_key_map["Medium"]
    sample_data = data_dict[sample_key]['Re-optimized']
    regions_list = [r for r in sample_data.keys() if r != 'World' and 'asia' not in r.lower()]
    regions_list.sort()

    # On récupère les paramètres de style (couleurs/styles)
    plot_params = plot_param_for_region(regions_list)

    fig, axs = plt.subplots(4, 3, figsize=(20, 18), sharex=True)

    # Stockage des données pour calculer les limites par ligne
    row_data_storage = [[] for _ in range(4)]
    global_handles = []

    # --- 1. CALCUL ET TRACÉ DES DONNÉES ---
    for col_idx, dmg in enumerate(damage_levels):
        key = damage_key_map[dmg]
        axs[0, col_idx].set_title(col_titles[col_idx], fontsize=18, weight='bold', pad=20)

        data_reopt = data_dict[key]['Re-optimized']
        data_nonreopt = data_dict[key]['Non-reoptimized']

        for region in regions_list:
            # Data extraction
            mac_non = np.array(data_nonreopt[region][VAR_ABAT])[:PLOT_LIMIT]
            mcd_non = np.array(data_nonreopt[region][VAR_DAM])[:PLOT_LIMIT]
            net_non = mcd_non - mac_non

            mac_re = np.array(data_reopt[region][VAR_ABAT])[:PLOT_LIMIT]
            mcd_re = np.array(data_reopt[region][VAR_DAM])[:PLOT_LIMIT]
            net_re = mcd_re - mac_re
            diff_val = net_re - net_non

            # Stockage
            row_data_storage[0].append(mac_non)
            row_data_storage[1].append(mcd_non)
            row_data_storage[2].append(net_non)
            row_data_storage[3].append(diff_val)

            color = plot_params[region]['color']
            style = plot_params[region]['style']
            time_axis = TIME_STEPS[:PLOT_LIMIT]

            # Plot
            l, = axs[0, col_idx].plot(time_axis, mac_non, color=color, linestyle=style, lw=2.5)
            axs[1, col_idx].plot(time_axis, mcd_non, color=color, linestyle=style, lw=2.5)
            axs[2, col_idx].plot(time_axis, net_non, color=color, linestyle=style, lw=2.5)
            axs[3, col_idx].plot(time_axis, diff_val, color=color, linestyle=style, lw=2.5)

            if col_idx == 0: global_handles.append(l)

    # --- 2. CONFIGURATION DE L'ÉCHELLE LOG PAR LIGNE ---
    for r_idx in range(4):
        # Calcul du max de la ligne
        all_vals = np.concatenate(row_data_storage[r_idx])
        all_vals = all_vals[~np.isnan(all_vals)]
        abs_max = np.max(np.abs(all_vals)) if len(all_vals) > 0 else 1.0

        # linthresh : zone linéaire autour de zéro (ex: en dessous de 1.0 ou 10^0)
        # Si tes valeurs sont énormes (10^10), on peut mettre 1.0 ou 10.0
        l_thresh = 1.0

        for c_idx in range(3):
            ax = axs[r_idx, c_idx]

            # Application de l'échelle symétrique log
            ax.set_yscale('symlog', linthresh=l_thresh, linscale=1.0)

            # Limites symétriques pour la ligne
            ax.set_ylim(-abs_max * 1.5, abs_max * 1.5)

            # --- FORCER L'APPARENCE LOGARITHMIQUE ---
            # On force Matplotlib à afficher les puissances de 10
            ax.yaxis.set_major_locator(mpl.ticker.SymmetricalLogLocator(base=10, linthresh=l_thresh))
            ax.yaxis.set_major_formatter(mpl.ticker.LogFormatterSciNotation(base=10))

            ax.tick_params(axis='both', which='major', labelsize=12, width=2, length=8)
            ax.tick_params(axis='both', which='minor', width=1, length=4)

            # Grille complète (majeure et mineure pour l'aspect log)
            ax.grid(True, which="both", linestyle='--', alpha=0.3)
            ax.axhline(0, color='black', linewidth=1.2, alpha=0.7, zorder=5)

            if c_idx > 0:
                ax.tick_params(labelleft=False)

    # Labels axes
    for row_idx in range(4):
        axs[row_idx, 0].set_ylabel(row_labels[row_idx], fontsize=14, weight='bold', labelpad=15)
    for col_idx in range(3):
        axs[3, col_idx].set_xlabel("Year", fontsize=14)

    # Légende
    fig.legend(global_handles[:len(regions_list)], regions_list,
               loc='lower center', bbox_to_anchor=(0.5, 0.02), ncol=8, frameon=True, fontsize=12)

    fig.suptitle("Analyse des Coûts et Incitations (Échelle SymLog)", fontsize=22, weight='bold', y=0.97)

    plt.tight_layout()
    plt.subplots_adjust(top=0.92, bottom=0.10, hspace=0.2, wspace=0.1)

    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')

    plt.show()

if __name__ == "__main__":

    BASE_DIR = Path(__file__).resolve().parents[1]
    OUTPUTS_DIR = BASE_DIR / "outputs"


    def load_output(filename):
        return read_uncerainties_results(os.path.join(OUTPUTS_DIR, filename))


    # Chargement d_ (Standards)
    d_nash = load_output("rice2023_nash_nonreopt.csv")
    d_q_nash = load_output("rice2023_nash_quad_nonreopt.csv")


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

    # plot_sign_structure_grid(data_dict)
    plot_value_structure_grid(data_dict,save_path = 'marginal_information.png' )