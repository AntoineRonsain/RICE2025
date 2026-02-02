import os
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
from pathlib import Path
from tools.analysis_tools import plot_param_for_region
from tools.tools import read_results
from tools.compute_st_dev import compute_dispersion
import string


# --- CONFIGURATION ---
START_YEAR = 2020
N_STEPS = 101
PLOT_STEPS = 37  # Plot only up to this index (approx year 2200)

STYLE = {
    'font_size_title': 20,
    'font_size_label': 25,
    'font_size_tick': 15,
    'font_size_legend': 20,
    'line_width': 2,
}


def get_miu_limit_curve(n_steps):
    """
    Computes the physical upper limit curve for emission control rates.
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



def plot_emissions_grid(data, scenarios, regions, plot_params, miu_limit, scenario_labels):
    """
    Trace les taux de contrôle des émissions en grille.
    - Ajoute a., b., c. devant les titres.
    - Centre les titres.
    - Place la légende dans le 4ème emplacement vide sur 2 colonnes.
    """
    years = [START_YEAR + i * 5 for i in range(N_STEPS)]

    # Liste des lettres pour les sous-titres
    letters = string.ascii_lowercase

    # Setup grid
    nb_cols = 2
    nb_rows = int(np.ceil(len(scenarios) / nb_cols))

    mpl.rc('xtick', labelsize=STYLE['font_size_tick'])
    mpl.rc('ytick', labelsize=STYLE['font_size_tick'])

    fig, axs = plt.subplots(nb_rows, nb_cols, figsize=(16, 12))
    axes_flat = axs.flatten()

    global_handles, global_labels = None, None

    for i, ax in enumerate(axes_flat):
        if i < len(scenarios):
            sce = scenarios[i]

            # Calcul de la dispersion
            mu_dict = {r: data[sce][r]["Emissions control rate"][:90] for r in regions}
            epsilon = compute_dispersion(mu_dict)

            # Trace de la limite
            ax.plot(years[:PLOT_STEPS], miu_limit[:PLOT_STEPS],
                    linewidth=2, color='black', label="Maximum")

            # Trace des régions
            for r in regions:
                series = data[sce][r]["Emissions control rate"][:PLOT_STEPS]
                ax.plot(years[:PLOT_STEPS], series,
                        color=plot_params[r]['color'],
                        linestyle=plot_params[r]["style"],
                        label=r, linewidth=1)

            # --- TITRE CENTRÉ AVEC LETTRE ---
            current_letter = letters[i]

            title_text = (
                    r"$\bf{" + current_letter + ".}$ " +
                    f"{scenario_labels[sce]} ($\epsilon = {np.round(epsilon, 3)}$)"
            )

            # Modification ici : loc='center' (ou suppression de l'argument car c'est le défaut)
            ax.set_title(title_text, fontsize=STYLE['font_size_title'], loc='center')

            ax.set_ylim(0, 1.2)

            # Capture de la légende
            if i == 0:
                global_handles, global_labels = ax.get_legend_handles_labels()

        else:
            # --- Emplacement vide pour la légende ---
            ax.set_axis_off()

            if global_handles and global_labels:
                ax.legend(global_handles, global_labels,
                          loc='center',
                          ncol=2,
                          fontsize=STYLE['font_size_legend'],
                          frameon=True)

    plt.tight_layout()
    plt.show()


def plot_global_indicators(data, scenarios, regions, scenario_labels):
    """
    Plots GDP per Capita and Atmospheric Temperature side-by-side.
    Adds titles with 'a.' and 'b.' labels.
    """
    years = [START_YEAR + i * 5 for i in range(N_STEPS)]

    fig, (ax_gdp, ax_temp) = plt.subplots(1, 2, figsize=(18, 8))

    for sce in scenarios:
        # Aggregation
        gdp_total = np.zeros(N_STEPS)
        pop_total = np.zeros(N_STEPS)

        for r in regions:
            gdp_total += np.array(data[sce][r]["Output, net net trill 2019$"])
            pop_total += np.array(data[sce][r]["Population (exogenous)"])

        gdp_capita = (gdp_total / pop_total) * 1000  # Convert to k$
        temp_world = data[sce]['World']["Atmospheric temperature (deg c above preind)"]

        # Plotting
        label = scenario_labels[sce]
        ax_gdp.plot(years[:PLOT_STEPS], gdp_capita[:PLOT_STEPS], label=label, linewidth=3)
        ax_temp.plot(years[:PLOT_STEPS], temp_world[:PLOT_STEPS], label=label, linewidth=3)

    # --- Formatting GDP Plot (a.) ---
    # Ajout du titre a.
    ax_gdp.set_title(r"a. GDP per capita (000$ /hab)", fontsize=STYLE['font_size_label'], loc='center')
    ax_gdp.set_xlabel('Time', fontsize=STYLE['font_size_label'])
    ax_gdp.legend(fontsize=STYLE['font_size_legend'])

    # --- Formatting Temp Plot (b.) ---
    # Ajout du titre b.
    ax_temp.set_title(r"b. Atmospheric Temperature (°C)", fontsize=STYLE['font_size_label'], loc='center')
    ax_temp.set_xlabel('Time', fontsize=STYLE['font_size_label'])

    # Tick sizing
    for ax in [ax_gdp, ax_temp]:
        ax.tick_params(axis='both', which='major', labelsize=STYLE['font_size_label'])
        ax.grid(True, linestyle='--', alpha=0.5)

    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    # 1. Load Data
    path = Path(__file__).resolve().parents[1]
    outputs_dir = path / "spatial_consistency/outputs"

    data = read_results(os.path.join(outputs_dir, "rice2023_negishi.csv"))
    data_quad = read_results(os.path.join(outputs_dir, "rice2023_negishi_quad.csv"))

    # data = read_results(os.path.join(outputs_dir, "rice2023_nash.csv"))
    # data_quad = read_results(os.path.join(outputs_dir, "rice2023_nash_quad.csv"))

    # Merge/Patch Data (Replacing Low Damage with Quad data as per original script)
    data["Low Damage"] = data_quad["Low Damage"]

    # 2. Setup Meta-data
    scenario_mapping = {
        "Low Damage": "Low Damage",
        "Medium Damage": "Medium Damage",
        "High Damage": "High Damage",
    }

    # Order scenarios based on the dictionary keys
    active_scenarios = list(scenario_mapping.keys())

    # Extract regions (excluding World)
    region_list = list(data[active_scenarios[0]].keys())
    if 'World' in region_list:
        region_list.remove('World')

    # Get graphic parameters
    region_plot_params = plot_param_for_region(region_list)
    miu_limit_curve = get_miu_limit_curve(N_STEPS)

    # 3. Plots
    plot_emissions_grid(data, active_scenarios, region_list, region_plot_params,
                        miu_limit_curve, scenario_mapping)

    plot_global_indicators(data, active_scenarios, region_list, scenario_mapping)