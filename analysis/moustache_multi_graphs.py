import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
from tools.tools import read_uncerainties_results

# --- CONFIGURATION ---
STEPS = 90
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

    def read(filename):
        return read_uncerainties_results(os.path.join(outputs_dir, filename))

    # Load raw files
    d_negishi = read("rice2023_negishi.csv")
    d10_negishi = read("rice2023_negishi_10asia.csv")
    d_nash = read("rice2023_nash.csv")
    d10_nash = read("rice2023_nash_10asia.csv")

    d_n_negishi = read("rice2023_nordhaus_negishi.csv")
    d10_n_negishi = read("rice2023_nordhaus_negishi_10asia.csv")
    d_n_nash = read("rice2023_nordhaus_nash.csv")
    d10_n_nash = read("rice2023_nordhaus_nash_10asia.csv")

    # Structure data with keys matching 'Solver + Damage' format
    data_dict = {
        'Negishi + Low Damage': {
            '1Asia': d_n_negishi['Nordhaus'], '10Asia': d10_n_negishi['Nordhaus']},
        'Negishi + Middle Damage': {
            '1Asia': d_negishi['Middle-Damage'], '10Asia': d10_negishi['Middle-Damage']},
        'Negishi + Strong Damage': {
            '1Asia': d_negishi['Standard'], '10Asia': d10_negishi['Standard']},
        'Nash + Low Damage': {
            '1Asia': d_n_nash['Nordhaus'], '10Asia': d10_n_nash['Nordhaus']},
        'Nash + Middle Damage': {
            '1Asia': d_nash['Middle-Damage'], '10Asia': d10_nash['Middle-Damage']},
        'Nash + Strong Damage': {
            '1Asia': d_nash['Standard'], '10Asia': d10_nash['Standard']}
    }

    return data_dict


def process_regional_emissions(data_dict):
    """
    Calculates the difference in emission control rates for non-Asian regions.
    """
    records = []
    for key, content in data_dict.items():
        solver, damage = key.split(' + ')

        for region in content['1Asia']:
            if region not in ["World", "ASIA"]:
                # Calculate difference: Disaggregated - Aggregated
                diff = (np.array(content['10Asia'][region]["Emissions control rate"][:STEPS]) -
                        np.array(content['1Asia'][region]["Emissions control rate"][:STEPS]))

                for val in diff:
                    records.append({
                        'region': region,
                        'value': val,
                        'solver': solver,
                        'damage': damage
                    })
    return pd.DataFrame(records)


def process_asia_comparison(data_dict):
    """
    Calculates the difference between the mean Sub-Asian region (ASIA0) and the global Asia region.
    """
    records = []
    for key, content in data_dict.items():
        solver, damage = key.split(' + ')

        # specific comparison: ASIA0 (from 10Asia) vs ASIA (from 1Asia)
        diff = (np.array(content['10Asia']['ASIA0']["Emissions control rate"][:STEPS]) -
                np.array(content['1Asia']['ASIA']["Emissions control rate"][:STEPS]))

        for val in diff:
            records.append({
                'region': 'Mean Sub-Asia vs Asia',
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
        delta_t = (np.array(content['10Asia']['World']["Atmospheric temperature (deg c above preind)"][:STEPS]) -
                   np.array(content['1Asia']['World']["Atmospheric temperature (deg c above preind)"][:STEPS]))

        # 2. CO2 Emissions Difference
        delta_co2 = (np.array(content['10Asia']['World']["Total CO2 Emissions, GTCO2/year"][:STEPS]) -
                     np.array(content['1Asia']['World']["Total CO2 Emissions, GTCO2/year"][:STEPS]))

        # 3. Relative GDP Difference
        # Summing regional GDPs (excluding World)
        gdp_1 = sum(np.array(content['1Asia'][r]["Output, net net trill 2019$"][:STEPS])
                    for r in content['1Asia'] if r != "World")
        gdp_10 = sum(np.array(content['10Asia'][r]["Output, net net trill 2019$"][:STEPS])
                     for r in content['10Asia'] if r != "World")

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


def plot_asia_comparison_side_by_side(df):
    """Side-by-side boxplot for Cooperative vs Non-Cooperative Asia comparison."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 8), sharey=True)

    scenarios = [('Negishi', 'Cooperative'), ('Nash', 'Non-cooperative')]

    for i, (solver_key, title) in enumerate(scenarios):
        sns.boxplot(
            data=df[df['solver'] == solver_key],
            x='region', y='value', hue='damage',
            ax=axes[i], palette="Set2"
        )
        axes[i].set_title(title, fontsize=STYLE['title_size'])
        axes[i].set_xlabel('')
        axes[i].set_ylabel('Diff. Emission Control', fontsize=STYLE['label_size'])
        axes[i].tick_params(axis='both', labelsize=STYLE['tick_size'])

        # Handle legends: remove from first, keep in second
        if i == 0:
            axes[i].get_legend().remove()
        else:
            axes[i].set_ylabel('')
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
    base_dir = Path(__file__).resolve().parents[2]
    data_dict = load_simulation_data(base_dir)

    # 2. Regional Emissions Analysis
    df_regions = process_regional_emissions(data_dict)
    plot_regional_boxplot(df_regions, 'Negishi', 'Regional Emissions Change (Cooperative)')
    plot_regional_boxplot(df_regions, 'Nash', 'Regional Emissions Change (Non-cooperative)')

    # 3. Asia Specific Comparison
    df_asia = process_asia_comparison(data_dict)
    plot_asia_comparison_side_by_side(df_asia)

    # 4. Global Indicators (GDP & Temp)
    df_global = process_global_indicators(data_dict)
    plot_global_impacts(df_global)