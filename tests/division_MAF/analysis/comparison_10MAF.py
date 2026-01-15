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
    outputs_dir = os.path.dirname(os.path.dirname((os.path.dirname((os.path.dirname(__file__))))))

    def read_file_MAF(filename, output_path = outputs_dir):
        output_path = os.path.join(output_path, "tests\division_MAF\output")
        return read_uncerainties_results(os.path.join(output_path, filename))

    def read_file_general(filename,output_path = outputs_dir):
        output_path = os.path.join(output_path, "spatial_consistency\outputs")
        return read_uncerainties_results(os.path.join(output_path, filename))

    d_negishi = read_file_general("rice2023_negishi.csv")
    d10_negishi = read_file_MAF("rice2023_negishi_10MAF.csv")
    d_q_negishi = read_file_general("rice2023_negishi_quad.csv")
    d10_q_negishi = read_file_MAF("rice2023_negishi_quad_10MAF.csv")

    d_nash = read_file_general("rice2023_nash.csv")
    d10_nash = read_file_MAF("rice2023_nash_10MAF.csv")
    d_q_nash = read_file_general("rice2023_nash_quad.csv")
    d10_q_nash = read_file_MAF("rice2023_nash_quad_10MAF.csv")

    data_dict = {
        'Non-Cooperative + Low Damage': {
            '1MAF': d_q_nash['Low Damage'], '10MAF': d10_q_nash['Low Damage']},
        'Non-Cooperative + Middle Damage': {
            '1MAF': d_nash['Medium Damage'], '10MAF': d10_nash['Medium Damage']},
        'Non-Cooperative + Strong Damage': {
            '1MAF': d_nash['High Damage'], '10MAF': d10_nash['High Damage']},

        'Cooperative + Low Damage': {
            '1MAF': d_q_negishi['Low Damage'], '10MAF': d10_q_negishi['Low Damage']},
        'Cooperative + Middle Damage': {
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
                'region': 'Mean Sub-MAF vs MAF',
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
        solver_label = 'Cooperative' if solver_raw == 'Negishi' else 'Non-cooperative'

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
    sns.boxplot(x='region', y='value', data=df[df['solver'] == solver_name], hue='damage', palette="Set2")

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
            ax=axes[i], palette="Set2"
        )
        axes[i].set_title(title, fontsize=STYLE['title_size'])
        axes[i].set_xlabel('')
        axes[i].set_ylabel('Diff. Emission Control', fontsize=STYLE['label_size'])
        axes[i].tick_params(axis='both', labelsize=STYLE['tick_size'])

        # Gestion sécurisée de la légende
        if i == 0:
            if axes[i].get_legend() is not None:
                axes[i].get_legend().remove()
        else:
            axes[i].set_ylabel('')
            # On ne force la légende que si des données ont été tracées
            if not df[df['solver'] == solver_key].empty:
                axes[i].legend(fontsize=STYLE['legend_size'])

    plt.tight_layout()
    plt.show()


def plot_global_impacts(df):
    """Side-by-side boxplot for Global GDP and Temperature."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # 1. GDP Plot
    sns.boxplot(
        data=df[df['metric'] == 'GDP (Relative)'],
        x='solver', y='value', hue='damage',
        ax=axes[0], palette="Set2"
    )
    axes[0].set_title('GDP (Relative Change)', fontsize=STYLE['title_size'])
    axes[0].set_ylabel('Fraction of GDP', fontsize=STYLE['label_size'])
    axes[0].set_xlabel('')
    axes[0].get_legend().remove()

    # 2. Temperature Plot
    sns.boxplot(
        data=df[df['metric'] == 'Temperature'],
        x='solver', y='value', hue='damage',
        ax=axes[1], palette="Set2"
    )
    axes[1].set_title('Temperature Increase (°C)', fontsize=STYLE['title_size'])
    axes[1].set_ylabel('Change in °C', fontsize=STYLE['label_size'])
    axes[1].set_xlabel('')
    axes[1].legend(fontsize=STYLE['legend_size'])

    for ax in axes:
        ax.tick_params(axis='both', labelsize=STYLE['tick_size'])
        ax.grid(axis='y', linestyle='--', alpha=0.5)

    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    # 1. Setup
    base_dir = Path(__file__).resolve().parents[1]
    data_dict = load_simulation_data(base_dir)

    # 2. Regional Emissions Analysis
    df_regions = process_regional_emissions(data_dict)

    # CORRECTION ICI : Utiliser 'Cooperative' au lieu de 'Negishi'
    plot_regional_boxplot(df_regions, 'Cooperative', 'Regional Emissions Change (Cooperative)')

    # CORRECTION ICI : Utiliser 'Non-Cooperative' au lieu de 'Nash'
    # Attention à bien respecter la casse définie dans load_simulation_data
    plot_regional_boxplot(df_regions, 'Non-Cooperative', 'Regional Emissions Change (Non-cooperative)')

    # 3. MAF Specific Comparison
    df_MAF = process_MAF_comparison(data_dict)
    plot_MAF_comparison_side_by_side(df_MAF)

    # 4. Global Indicators (GDP & Temp)
    df_global = process_global_indicators(data_dict)
    plot_global_impacts(df_global)