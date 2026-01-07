import os
import numpy as np
from pathlib import Path
from tabulate import tabulate

# Assuming these imports exist in your project
from tools.tools import read_uncerainties_results


def compute_mean_deviation(series1, series2):
    """
    Computes the mean deviation (bias) between two time series using Numpy.
    Formula: Mean(series1 - series2)

    Args:
        series1 (list/array): First time series (e.g., Sigma model).
        series2 (list/array): Second time series (e.g., Quad model).

    Returns:
        float: The mean difference.
    """
    s1 = np.array(series1)
    s2 = np.array(series2)

    # Ensure equal length for safety
    min_len = min(len(s1), len(s2))
    return np.mean(s1[:min_len] - s2[:min_len])


def generate_comparison_table(data_dict_1, data_dict_2):
    """
    Compares two datasets (e.g., Sigma vs Quad) across scenarios and regions.

    Args:
        data_dict_1 (dict): First dataset (Reference, e.g., Sigma).
        data_dict_2 (dict): Second dataset (Comparison, e.g., Quad).

    Returns:
        list: A list of rows ready for tabulation [Scenario, Mode, Region, Deviation].
    """
    table_rows = []

    # Iterate through Scenarios (e.g., Negishi, Nash)
    scenarios = list(data_dict_1.keys())

    for sce in scenarios:
        if sce not in data_dict_2:
            continue

        # Iterate through Modes (e.g., 1Asia, 10Asia)
        modes = list(data_dict_1[sce].keys())

        for mode in modes:
            if mode not in data_dict_2[sce]:
                continue

            # Get list of regions common to both datasets
            regions_1 = set(data_dict_1[sce][mode].keys())
            regions_2 = set(data_dict_2[sce][mode].keys())
            common_regions = list(regions_1.intersection(regions_2))

            # Filter out 'World' and sort for clean output
            if "World" in common_regions:
                common_regions.remove("World")
            common_regions.sort()

            for r in common_regions:
                # Extract time series (limit to 90 steps as in original code)
                val1 = data_dict_1[sce][mode][r]["Emissions control rate"][:90]
                val2 = data_dict_2[sce][mode][r]["Emissions control rate"][:90]

                dev = compute_mean_deviation(val1, val2)

                table_rows.append([sce, mode, r, dev])

    return table_rows


if __name__ == "__main__":
    # 1. Setup Paths
    BASE_DIR = Path(__file__).resolve().parents[2]  # Adjust parent level if needed
    OUTPUTS_DIR = BASE_DIR / "spatial_consistency/outputs"


    def load_data(filename):
        return read_uncerainties_results(os.path.join(OUTPUTS_DIR, filename))



    # Note: Variable names inferred from original code structure
    raw_negishi_sigm = load_data("rice2023_negishi.csv")
    raw_10negishi_sigm = load_data("rice2023_negishi_10asia.csv")
    raw_nash_sigm = load_data("rice2023_nash.csv")
    raw_10nash_sigm = load_data("rice2023_nash_10asia.csv")

    data_sigma = {
        'Negishi': {
            '1Asia': raw_negishi_sigm['Nordhaus'],
            '10Asia': raw_10negishi_sigm['Nordhaus']
        },
        'Nash': {
            '1Asia': raw_nash_sigm['Nordhaus'],
            '10Asia': raw_10nash_sigm['Nordhaus']
        },
    }

    # --- Load "Quad" Datasets (Nordhaus Specific) ---
    raw_negishi_quad = load_data("rice2023_nordhaus_negishi.csv")
    raw_10negishi_quad = load_data("rice2023_nordhaus_negishi_10asia.csv")
    raw_nash_quad = load_data("rice2023_nordhaus_nash.csv")
    raw_10nash_quad = load_data("rice2023_nordhaus_nash_10asia.csv")

    data_quad = {
        'Negishi': {
            '1Asia': raw_negishi_quad['Nordhaus'],
            '10Asia': raw_10negishi_quad['Nordhaus']
        },
        'Nash': {
            '1Asia': raw_nash_quad['Nordhaus'],
            '10Asia': raw_10nash_quad['Nordhaus']
        },
    }

    # 3. Compute and Display Table
    comparison_table = generate_comparison_table(data_sigma, data_quad)

    print("\n--- Deviation Table (Sigma vs Quad) ---")
    print(tabulate(comparison_table, headers=["Scenario", "Mode", "Region", "Deviation"], tablefmt="latex"))