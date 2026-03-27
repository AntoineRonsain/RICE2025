import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
from tools.tools import read_uncerainties_results

# --- CONFIGURATION ---
STEPS = 80
STYLE = {
    'title_size': 25,
    'label_size': 20,
    'tick_size': 16,
    'legend_size': 16,
}


def load_simulation_data(base_path):
    """
    Loads all simulation results and structures them into a standardized dictionary.

    Args:
        base_path (Path): Path to the project root.

    Returns:
        dict: A dictionary containing all scenarios structured by 'Solver + Damage'.
    """
    outputs_dir = base_path / "spatial_consistency/outputs"
    outputs_dir_MAF = base_path / "tests/division_MAF/outputs"

    def read_file(filename):
        return read_uncerainties_results(os.path.join(outputs_dir, filename))
    
    def read_file_MAF(filename):
        return read_uncerainties_results(os.path.join(outputs_dir_MAF, filename))

    d_negishi = read_file("rice2023_negishi.csv")
    d10_negishi = read_file_MAF("rice2023_negishi_10MAF.csv")
    d_q_negishi = read_file("rice2023_negishi_quad.csv")
    d10_q_negishi = read_file_MAF("rice2023_negishi_quad_10MAF.csv")

    d_nash = read_file("rice2023_nash.csv")
    d10_nash = read_file_MAF("rice2023_nash_10MAF.csv")
    d_q_nash = read_file("rice2023_nash_quad.csv")
    d10_q_nash = read_file_MAF("rice2023_nash_quad_10MAF.csv")

    data_dict = {
        'Non-Cooperative + Low Damage': {
            '1MAF': d_q_nash['Low Damage'], '10MAF': d10_q_nash['Low Damage']},
        'Non-Cooperative + Medium Damage': {
            '1MAF': d_nash['Medium Damage'], '10MAF': d10_nash['Medium Damage']},
        'Non-Cooperative + Strong Damage': {
            '1MAF': d_nash['High Damage'], '10MAF': d10_nash['High Damage']},

        'Cooperative + Low Damage': {
            '1MAF': d_q_negishi['Low Damage'], '10MAF': d10_q_negishi['Low Damage']},
        'Cooperative + Medium Damage': {
            '1MAF': d_negishi['Medium Damage'], '10MAF': d10_negishi['Medium Damage']},
        'Cooperative + Strong Damage': {
            '1MAF': d_negishi['High Damage'], '10MAF': d10_negishi['High Damage']},
    }

    return data_dict


def process_regional_emissions(data_dict):
    """
    Calculates the difference in emission control rates for non-MAFn regions.
    """
    records = []
    for key, content in data_dict.items():
        solver, damage = key.split(' + ')

        for region in content['1MAF']:
            if region not in ["World", "MAF"]:
                # Calculate difference: Disaggregated - Aggregated
                diff = (np.array(content['10MAF'][region]["Emissions control rate"][:STEPS]) -
                        np.array(content['1MAF'][region]["Emissions control rate"][:STEPS]))

                for val in diff:
                    records.append({
                        'region': region,
                        'value': val,
                        'solver': solver,
                        'damage': damage
                    })
    return pd.DataFrame(records)


def process_MAF_comparison(data_dict):
    """
    Calculates the difference between the mean Sub-MAFn region (MAF0) and the global MAF region.
    """
    records = []
    for key, content in data_dict.items():
        solver, damage = key.split(' + ')

        # specific comparison: MAF0 (from 10MAF) vs MAF (from 1MAF)
        diff = (np.array(content['10MAF']['MAF0']["Emissions control rate"][:STEPS]) -
                np.array(content['1MAF']['MAF']["Emissions control rate"][:STEPS]))

        for val in diff:
            records.append({
                'region': r'$\Delta\mu_{\mathrm{MAF}}$',
                'value': val,
                'solver': solver,
                'damage': damage
            })
    return pd.DataFrame(records)


def process_global_indicators(data_dict):
    """
    Calculates global differences for Temperature, CO2, and GDP (relative).
    """
    records = []
    for key, content in data_dict.items():
        solver_raw, damage = key.split(' + ')
        solver_label = 'Cooperative' if solver_raw == 'Cooperative' else 'Non-cooperative'

        # 1. Temperature Difference
        delta_t = (np.array(content['10MAF']['World']["Atmospheric temperature (deg c above preind)"][:STEPS]) -
                   np.array(content['1MAF']['World']["Atmospheric temperature (deg c above preind)"][:STEPS]))

        # 2. CO2 Emissions Difference
        delta_co2 = (np.array(content['10MAF']['World']["Total CO2 Emissions, GTCO2/year"][:STEPS]) -
                     np.array(content['1MAF']['World']["Total CO2 Emissions, GTCO2/year"][:STEPS]))

        # 3. Relative GDP Difference
        # Summing regional GDPs (excluding World)
        gdp_1 = sum(np.array(content['1MAF'][r]["Output, net net trill 2019$"][:STEPS])
                    for r in content['1MAF'] if r != "World")
        gdp_10 = sum(np.array(content['10MAF'][r]["Output, net net trill 2019$"][:STEPS])
                     for r in content['10MAF'] if r != "World")

        # Relative change: (New - Old) / Old
        delta_gdp_rel = (gdp_10 - gdp_1) / gdp_1

        for i in range(STEPS):
            records.append({'metric': 'Temperature', 'value': delta_t[i], 'solver': solver_label, 'damage': damage})
            records.append({'metric': 'CO2', 'value': delta_co2[i], 'solver': solver_label, 'damage': damage})
            records.append(
                {'metric': 'GDP (Relative)', 'value': delta_gdp_rel[i], 'solver': solver_label, 'damage': damage})

    return pd.DataFrame(records)


# --- PLOTTING FUNCTIONS ---

def plot_regional_boxplot(df, solver_name, title):
    """Generic boxplot for regional emissions."""
    plt.figure(figsize=(12, 8))
    sns.boxplot(x='region', y='value', data=df[df['solver'] == solver_name], hue='damage')

    plt.title(title, fontsize=STYLE['title_size'], pad=20)
    plt.legend(bbox_to_anchor=(1.02, 1), loc='upper left', fontsize=STYLE['legend_size'])
    plt.xlabel('Region', fontsize=STYLE['label_size'])
    plt.ylabel('Change in Emission Control', fontsize=STYLE['label_size'])
    plt.tick_params(axis='both', labelsize=STYLE['tick_size'])
    plt.grid(axis='y', linestyle='--', alpha=0.5)
    plt.tight_layout()
    plt.show()


def plot_MAF_comparison_side_by_side(df):
    """Side-by-side boxplot for Cooperative vs Non-Cooperative MAF comparison."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 8), sharey=True)

    # CORRECTION ICI : Remplacer 'Negishi'/'Nash' par les clés réelles du DataFrame
    scenarios = [('Cooperative', 'Cooperative'), ('Non-Cooperative', 'Non-cooperative')]

    for i, (solver_key, title) in enumerate(scenarios):
        # On filtre avec solver_key qui vaut maintenant 'Cooperative' ou 'Non-Cooperative'
        sns.boxplot(
            data=df[df['solver'] == solver_key],
            x='region', y='value', hue='damage',
            ax=axes[i]
        )
        axes[i].set_title(title, fontsize=STYLE['title_size'])
        axes[i].set_xlabel('')
        axes[i].set_ylabel('Diff. Emission Control', fontsize=STYLE['label_size'])
        axes[i].tick_params(axis='both', labelsize=STYLE['tick_size'])

        # Gestion sécurisée de la légende
        if i == 0:
            if not df[df['solver'] == solver_key].empty:
                axes[i].legend(fontsize=STYLE['legend_size'])
        else:
            if axes[i].get_legend() is not None:
                axes[i].get_legend().remove()
            axes[i].set_ylabel('')

    plt.tight_layout()
    plt.show()



def plot_global_impacts(df):
    """
    Trace les boxplots pour le PIB et la Température côte à côte.
    Force l'affichage de 'Cooperative' et 'Non-cooperative'.
    """
    sns.set_context("talk")
    sns.set_style("ticks")

    fig, axes = plt.subplots(1, 2, figsize=(18, 12))

    # --- CONFIGURATION DE L'ORDRE ---
    # C'est ici qu'on force l'affichage des deux, dans le bon ordre
    order_solver = ["Cooperative", "Non-cooperative"]
    # On force aussi l'ordre des dégâts pour que les couleurs correspondent (Bleu, Orange, Vert)
    order_damage = ["Low Damage", "Medium Damage", "Strong Damage"]


    # 1. Graphique PIB (GDP)
    sns.boxplot(
        data=df[df['metric'] == 'GDP (Relative)'],
        x='solver', y='value', hue='damage',
        ax=axes[0],
        order=order_solver,  # <--- Force l'ordre X
        hue_order=order_damage,  # <--- Force l'ordre des couleurs
        width=0.6,
        linewidth=1.5,
        showfliers=True
    )

    axes[0].set_title(r"$\bf{a.}$ GDP (relative change)", fontsize=26, loc='left', pad=15)
    axes[0].set_ylabel('')
    axes[0].set_xlabel('')
    axes[0].get_legend().remove()

    # 2. Graphique Température
    sns.boxplot(
        data=df[df['metric'] == 'Temperature'],
        x='solver', y='value', hue='damage',
        ax=axes[1],
        order=order_solver,  # <--- Force l'ordre X ici aussi
        hue_order=order_damage,  # <--- Force l'ordre des couleurs
        width=0.6,
        linewidth=1.5
    )

    axes[1].set_title(r"$\bf{b.}$ Increase in temperature (in °C)", fontsize=26, loc='left', pad=15)
    axes[1].set_ylabel('')
    axes[1].set_xlabel('')

    # Légende propre
    axes[1].legend(fontsize=20, loc='upper left', title=None, frameon=True)

    # Formatage final
    for ax in axes:
        ax.tick_params(axis='both', labelsize=22)
        ax.grid(False)
        # Ajout des bordures noires (spines)
        for spine in ax.spines.values():
            spine.set_edgecolor('black')
            spine.set_linewidth(1.2)

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    # 1. Setup
    base_dir = Path(__file__).resolve().parents[3]
    data_dict = load_simulation_data(base_dir)

    # 2. Regional Emissions Analysis
    df_regions = process_regional_emissions(data_dict)

    plot_regional_boxplot(df_regions, 'Cooperative', 'Regional Emissions Control Rate Change (Cooperative)')

    plot_regional_boxplot(df_regions, 'Non-Cooperative', 'Regional Emissions Control Rate Change (Non-cooperative)')

    # 3. MAF Specific Comparison
    df_MAF = process_MAF_comparison(data_dict)
    plot_MAF_comparison_side_by_side(df_MAF)

    # 4. Global Indicators (GDP & Temp)
    df_global = process_global_indicators(data_dict)
    plot_global_impacts(df_global)