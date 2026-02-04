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
    Trace une grille 5x3 basée uniquement sur le SIGNE (+/-).

    Méthode de visualisation :
    - On ignore la valeur absolue.
    - Si Val > 0 : On trace une ligne dans la zone positive (autour de +1).
    - Si Val < 0 : On trace une ligne dans la zone négative (autour de -1).
    - Si Val = 0 : On trace sur la ligne zéro.

    Chaque région a un léger décalage (offset) vertical pour qu'on puisse
    distinguer les courbes sans qu'elles se chevauchent.
    """
    damage_levels = ["Low", "Medium", "Strong"]
    col_titles = ["Low Damage", "Medium Damage", "High Damage"]

    row_labels = [
        r"$\bf{MAC}$" + "\n(1 Asia)",
        r"$\bf{MCD}$" + "\n(1 Asia)",
        r"$\bf{Net}$" + "\n(1 Asia)",
        r"$\bf{Net}$" + "\n(10 Asia)",
        r"$\bf{Différence}$" + "\n(10 - 1)"
    ]

    damage_key_map = {
        "Low": "Low Damage",
        "Medium": "Medium Damage",
        "Strong": "High Damage"
    }

    # Configuration globale
    mpl.rc('xtick', labelsize=10)
    mpl.rc('ytick', labelsize=10)

    # Récupération des régions
    sample_key = damage_key_map["Medium"]
    sample_data = data_dict[sample_key]['1Asia']
    regions_list = [r for r in sample_data.keys() if r not in ['World', 'ASIA', 'Asia']]
    regions_list.sort()

    plot_params = plot_param_for_region(regions_list)

    # Paramètre d'espacement pour éviter le chevauchement
    # Plus ce chiffre est grand, plus les lignes sont écartées
    OFFSET_STEP = 0.15

    # Création de la figure
    fig, axs = plt.subplots(5, 3, figsize=(18, 20), sharex=True, sharey=True)

    global_handles, global_labels = [], []

    for col_idx, dmg in enumerate(damage_levels):
        key = damage_key_map[dmg]

        axs[0, col_idx].set_title(col_titles[col_idx], fontsize=16, weight='bold', pad=20)

        data_1 = data_dict[key]['1Asia']
        data_10 = data_dict[key]['10Asia']

        for idx, region in enumerate(regions_list):
            if region not in data_1 or region not in data_10:
                continue

            # --- CALCUL DES DONNÉES BRUTES ---
            mac_1 = np.array(data_1[region][VAR_ABAT])[:PLOT_LIMIT]
            mcd_1 = np.array(data_1[region][VAR_DAM])[:PLOT_LIMIT]
            net_1 = mac_1 - mcd_1

            mac_10 = np.array(data_10[region][VAR_ABAT])[:PLOT_LIMIT]
            mcd_10 = np.array(data_10[region][VAR_DAM])[:PLOT_LIMIT]
            net_10 = mac_10 - mcd_10

            diff_net = net_10 - net_1

            # --- TRANSFORMATION EN SIGNE DÉCALÉ ---
            # Formule : signe(valeur) * (1 + index * step)
            # Résultat : Les courbes positives s'empilent vers le haut,
            #            les négatives vers le bas.

            # Fonction locale pour transformer les données
            def to_sign_offset(arr, i):
                signs = np.sign(arr)
                # On met à 0 les valeurs très proches de 0 (bruit numérique)
                signs[np.abs(arr) < 1e-9] = 0
                # Application de l'offset seulement si non nul
                offset = 1 + (i * OFFSET_STEP)
                return signs * offset

            y_mac_1 = to_sign_offset(mac_1, idx)
            y_mcd_1 = to_sign_offset(mcd_1, idx)
            y_net_1 = to_sign_offset(net_1, idx)
            y_net_10 = to_sign_offset(net_10, idx)
            y_diff = to_sign_offset(diff_net, idx)

            # Style
            color = plot_params[region]['color']
            style = plot_params[region]['style']
            lw = 2.5  # Lignes épaisses pour bien voir

            # --- TRACÉ ---
            l1, = axs[0, col_idx].plot(TIME_STEPS[:PLOT_LIMIT], y_mac_1,
                                       color=color, linestyle=style, linewidth=lw, label=region)
            axs[1, col_idx].plot(TIME_STEPS[:PLOT_LIMIT], y_mcd_1,
                                 color=color, linestyle=style, linewidth=lw)
            axs[2, col_idx].plot(TIME_STEPS[:PLOT_LIMIT], y_net_1,
                                 color=color, linestyle=style, linewidth=lw)
            axs[3, col_idx].plot(TIME_STEPS[:PLOT_LIMIT], y_net_10,
                                 color=color, linestyle=style, linewidth=lw)
            axs[4, col_idx].plot(TIME_STEPS[:PLOT_LIMIT], y_diff,
                                 color=color, linestyle=style, linewidth=lw)

            if col_idx == 0:
                global_handles.append(l1)
                global_labels.append(region)

        # --- MISE EN PAGE DES GRAPHIQUES ---
        for row in range(5):
            ax = axs[row, col_idx]

            # Ligne Zéro très visible
            ax.axhline(0, color='black', linewidth=3, alpha=1.0)

            # Suppression des ticks Y chiffrés (car l'échelle est artificielle)
            ax.set_yticks([])

            # Ajout d'indications textuelles "Positif" / "Négatif" en arrière-plan
            if col_idx == 0:  # Seulement sur la première colonne pour ne pas surcharger
                ylim = ax.get_ylim()
                # On écrit "Positif" en haut et "Négatif" en bas
                ax.text(START_YEAR + 2, 2, "Positif (+)", fontsize=9, color='gray', alpha=0.5, va='bottom')
                ax.text(START_YEAR + 2, -2, "Négatif (-)", fontsize=9, color='gray', alpha=0.5, va='top')

    # Labels des lignes
    for row_idx in range(5):
        axs[row_idx, 0].set_ylabel(row_labels[row_idx], fontsize=12, weight='bold', labelpad=10)

    # Labels X
    for col_idx in range(3):
        axs[4, col_idx].set_xlabel("Année", fontsize=12)

    # --- Légende ---
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
        loc='lower center',
        bbox_to_anchor=(0.5, 0.01),
        ncol=6,
        fontsize=12,
        title="Régions (Ordre d'empilement)",
        title_fontsize=14,
        frameon=True,
        edgecolor='gray'
    )

    fig.suptitle("Analyse Structurelle des Signes (Positif vs Négatif)", fontsize=22, weight='bold', y=0.99)

    plt.tight_layout()
    plt.subplots_adjust(top=0.93, bottom=0.08, left=0.08)
    plt.show()


if __name__ == "__main__":
    BASE_DIR = Path(__file__).resolve().parents[1]
    OUTPUTS_DIR = BASE_DIR / "spatial_consistency/outputs"


    def load_data(filename):
        return read_uncerainties_results(os.path.join(OUTPUTS_DIR, filename))


    d_nash = load_data("rice2023_nash.csv")
    d_q_nash = load_data("rice2023_nash_quad.csv")
    d10_nash = load_data("rice2023_nash_10asia.csv")
    d10_q_nash = load_data("rice2023_nash_quad_10asia.csv")

    data_dict = {
        'Low Damage': {
            '1Asia': d_q_nash['Low Damage'], '10Asia': d10_q_nash['Low Damage']
        },
        'Medium Damage': {
            '1Asia': d_nash['Medium Damage'], '10Asia': d10_nash['Medium Damage']
        },
        'High Damage': {
            '1Asia': d_nash['High Damage'], '10Asia': d10_nash['High Damage']
        }
    }

    plot_sign_structure_grid(data_dict)
