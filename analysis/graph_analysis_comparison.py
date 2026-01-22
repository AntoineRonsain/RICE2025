import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path

# Assuming these exist in your project structure
from tools.tools import read_uncerainties_results

# --- CONFIGURATION ---
# Plot styling parameters for publication quality
STYLE_CONFIG = {
    'font_scale': 1.5,
    'title_size': 35,
    'axis_label_size': 25,
    'tick_size': 25,
    'legend_size': 20,
    'line_width': 2.5
}


def load_scenario_data(base_path):
    """
    Loads all RICE results files and structures them into a dictionary.

    Args:
        base_path (Path): Path to the project root.

    Returns:
        dict: Structured dictionary containing all scenarios.
    """
    output_dir = base_path / "spatial_consistency/outputs"

    def read_file(filename):
        return read_uncerainties_results(os.path.join(output_dir, filename))


    d_negishi = read_file("rice2023_negishi.csv")
    d10_negishi = read_file("rice2023_negishi_10asia.csv")
    d_q_negishi = read_file("rice2023_negishi_quad.csv")
    d10_q_negishi = read_file("rice2023_negishi_quad_10asia.csv")

    d_nash = read_file("rice2023_nash.csv")
    d10_nash = read_file("rice2023_nash_10asia.csv")
    d_q_nash = read_file("rice2023_nash_quad.csv")
    d10_q_nash = read_file("rice2023_nash_quad_10asia.csv")

    full_data = {
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


    # Slice data to the first 90 time steps to ensure consistency
    for model in full_data:
        for resolution in full_data[model]:
            for region in full_data[model][resolution]:
                for param in full_data[model][resolution][region]:
                    full_data[model][resolution][region][param] = \
                        full_data[model][resolution][region][param][:90]

    return full_data


def create_boxplot(df, x_col, y_col, hue_col, title, ylabel="", xlabel="", legend_loc='upper left'):
    """
    Generic function to create a standardized boxplot using Seaborn.

    Args:
        df (pd.DataFrame): Data source.
        x_col (str): Column for x-axis.
        y_col (str): Column for y-axis.
        hue_col (str): Column for grouping (color).
        title (str): Chart title.
        ylabel (str, optional): Y-axis label.
        xlabel (str, optional): X-axis label.
        legend_loc (str, optional): Location of the legend.
    """
    plt.figure(figsize=(16, 10))
    sns.set_style("whitegrid")

    ax = sns.boxplot(x=x_col, y=y_col, data=df, hue=hue_col, linewidth=STYLE_CONFIG['line_width'])

    ax.set_title(title, fontsize=STYLE_CONFIG['title_size'], pad=20)
    ax.set_xlabel(xlabel, fontsize=STYLE_CONFIG['axis_label_size'])
    ax.set_ylabel(ylabel, fontsize=STYLE_CONFIG['axis_label_size'])

    ax.tick_params(axis='both', which='major', labelsize=STYLE_CONFIG['tick_size'])

    # Legend handling
    if legend_loc == 'outside':
        plt.legend(bbox_to_anchor=(1.02, 1), loc='upper left', borderaxespad=0, fontsize=STYLE_CONFIG['legend_size'])
    else:
        plt.legend(loc=legend_loc, fontsize=STYLE_CONFIG['legend_size'], frameon=True, framealpha=0.9)

    plt.tight_layout()
    plt.show()


# --- DATA PROCESSING FUNCTIONS ---

def prep_emission_control_diff(data_dict):
    """Prepares data for regional emission control differences."""
    records = []
    for m in data_dict:
        # Iterate over regions, excluding aggregates
        for r in data_dict[m]['1Asia']:
            if r not in ["World", "ASIA"]:
                # Difference: 10Asia (Disaggregated) - 1Asia (Global)
                diff = (np.array(data_dict[m]['10Asia'][r]["Emissions control rate"]) -
                        np.array(data_dict[m]['1Asia'][r]["Emissions control rate"]))

                for val in diff:
                    records.append({'region': r, 'value': val, 'model': m})
    return pd.DataFrame(records)


def prep_asia_subregion_diff(data_dict):
    """Prepares data for specific sub-Asian region comparisons."""
    records = []
    for m in data_dict:
        d10 = data_dict[m]['10Asia']
        d1 = data_dict[m]['1Asia']

        diff_intra = np.array(d10['ASIA0']["Emissions control rate"]) - np.array(d10['ASIA2']["Emissions control rate"])
        for val in diff_intra:
            records.append({'comparison': '"Sub-Asia n°1" / "Sub-Asia n°3"', 'value': val, 'model': m})


        diff_inter = np.array(d10['ASIA0']["Emissions control rate"]) - np.array(d1['ASIA']["Emissions control rate"])
        for val in diff_inter:
            records.append({'comparison': '"Sub-Asia n°X" / Asia', 'value': val, 'model': m})

    return pd.DataFrame(records)


def prep_global_params_diff(data_dict):
    """Prepares data for global Temperature and CO2 differences."""
    records = []
    for m in data_dict:
        # Temperature
        delta_t = (np.array(data_dict[m]['10Asia']['World']["Atmospheric temperature (deg c above preind)"]) -
                   np.array(data_dict[m]['1Asia']['World']["Atmospheric temperature (deg c above preind)"]))

        # CO2 Emissions
        delta_co2 = (np.array(data_dict[m]['10Asia']['World']["Total CO2 Emissions, GTCO2/year"]) -
                     np.array(data_dict[m]['1Asia']['World']["Total CO2 Emissions, GTCO2/year"]))

        for t_val, co2_val in zip(delta_t, delta_co2):
            records.append({'param': 'Temperature', 'value': t_val, 'model': m})
            records.append({'param': 'CO2 Emissions', 'value': co2_val, 'model': m})

    return pd.DataFrame(records)


def prep_gdp_diff(data_dict):
    """Prepares data for global GDP differences (sum of regions)."""
    records = []
    for m in data_dict:
        # Sum GDP across all regions (excluding World) for both models
        gdp_1 = sum(np.array(data_dict[m]['1Asia'][r]["Output, net net trill 2019$"])
                    for r in data_dict[m]['1Asia'] if r != "World")

        gdp_10 = sum(np.array(data_dict[m]['10Asia'][r]["Output, net net trill 2019$"])
                     for r in data_dict[m]['10Asia'] if r != "World")

        delta_y = gdp_10 - gdp_1
        for val in delta_y:
            records.append({'param': 'Change in GDP', 'value': val, 'model': m})
    return pd.DataFrame(records)


def prep_gdp_per_capita_diff(data_dict):
    """Prepares data for GDP per capita differences."""
    records = []
    for m in data_dict:
        # Sum GDP and Population
        gdp_1 = sum(np.array(data_dict[m]['1Asia'][r]["Output, net net trill 2019$"])
                    for r in data_dict[m]['1Asia'] if r != "World")
        pop_1 = sum(np.array(data_dict[m]['1Asia'][r]["Population (exogenous)"])
                    for r in data_dict[m]['1Asia'] if r != "World")

        gdp_10 = sum(np.array(data_dict[m]['10Asia'][r]["Output, net net trill 2019$"])
                     for r in data_dict[m]['10Asia'] if r != "World")

        # Note: Population is exogenous and should be identical, using pop_1 for normalization
        # Formula: (Delta GDP / Total Pop) * 1000 to get $/capita
        delta_y_capita = ((gdp_10 - gdp_1) / pop_1) * 1000

        for val in delta_y_capita:
            records.append({'param': 'Change in GDP per capita', 'value': val, 'model': m})
    return pd.DataFrame(records)


if __name__ == "__main__":

    base_dir = Path(__file__).resolve().parents[1]

    data_dict = load_scenario_data(base_dir)

    df_emissions = prep_emission_control_diff(data_dict)
    create_boxplot(
        df_emissions, x_col='region', y_col='value', hue_col='model',
        title='Change in Emission Control (Regional)',
        legend_loc='outside'
    )

    df_asia = prep_asia_subregion_diff(data_dict)
    create_boxplot(
        df_asia, x_col='comparison', y_col='value', hue_col='model',
        title='Asian Sub-regional Differences',
        legend_loc='outside'
    )

    df_global = prep_global_params_diff(data_dict)
    create_boxplot(
        df_global[df_global['param'] == 'Temperature'],
        x_col='param', y_col='value', hue_col='model',
        title='Change in Temperature (°C)',
        ylabel='Delta °C',
        legend_loc='upper right'
    )

    create_boxplot(
        df_global[df_global['param'] == 'CO2 Emissions'],
        x_col='param', y_col='value', hue_col='model',
        title='Change in CO2 Emissions',
        ylabel='Gt CO2',
        legend_loc='upper right'
    )

    df_gdp = prep_gdp_diff(data_dict)
    create_boxplot(
        df_gdp, x_col='param', y_col='value', hue_col='model',
        title='Change in Total GDP',
        ylabel='Trillion 2019$',
        legend_loc='upper right'
    )

    df_gdp_capita = prep_gdp_per_capita_diff(data_dict)
    create_boxplot(
        df_gdp_capita, x_col='param', y_col='value', hue_col='model',
        title='Change in GDP per Capita',
        ylabel='000 $/hab',
        legend_loc='lower right'
    )