import numpy as np
import os
from pathlib import Path
from tabulate import tabulate

from tools.tools import *
from tools.compute_st_dev import *
from tools.analysis_tools import *


def compute_deviation_vectorized(var, ref):
    """
    Calcule la différence moyenne (biais) entre deux séries temporelles via Numpy.
    Remplace l'ancienne boucle for lente.
    """
    var_arr = np.array(var)
    ref_arr = np.array(ref)

    if var_arr.shape != ref_arr.shape:
        min_len = min(len(var_arr), len(ref_arr))
        var_arr = var_arr[:min_len]
        ref_arr = ref_arr[:min_len]

    return np.mean(var_arr - ref_arr)


def content_table(data_dict):
    variation = []
    sce_list = list(data_dict.keys())

    ref_scenario = sce_list[0]
    region_list = list(data_dict[ref_scenario]['1Asia'].keys())

    if "World" in region_list:
        region_list.remove("World")

    for r in region_list:
        row_buffer = [r]

        for sce in sce_list:
            data_10asia = data_dict[sce]['10Asia']
            data_1asia = data_dict[sce]['1Asia']

            if "ASIA" in r:
                mu_dict = {
                    r2: data_10asia[r2]["Emissions control rate"][:90]
                    for r2 in data_10asia.keys() if "ASIA" in r2
                }

                aggregated_mean = compute_mean(mu_dict)
                reference_series = data_1asia[r]["Emissions control rate"][:90]

                dev = compute_deviation_vectorized(aggregated_mean, reference_series)

            else:
                series_10 = data_10asia[r]["Emissions control rate"][:90]
                series_1 = data_1asia[r]["Emissions control rate"][:90]

                dev = compute_deviation_vectorized(series_10, series_1)

            row_buffer.append(np.round(dev, 3))

        variation.append(row_buffer)

    return variation


if __name__ == "__main__":
    BASE_DIR = Path(__file__).resolve().parents[3]
    OUTPUTS_DIR = BASE_DIR / "chapter_rice_consistency/spatial_consistency/outputs"


    def load_rice_data(filename):
        return read_uncerainties_results(os.path.join(OUTPUTS_DIR, filename))


    data_negishi = load_rice_data("rice2023_negishi.csv")
    data10_negishi = load_rice_data("rice2023_negishi_10asia.csv")
    data_q_negishi = load_rice_data("rice2023_quad_negishi.csv")
    data10_q_negishi = load_rice_data("rice2023_quad_negishi_10asia.csv")

    data_nash = load_rice_data("rice2023_nash.csv")
    data10_nash = load_rice_data("rice2023_nash_10asia.csv")
    data_q_nash = load_rice_data("rice2023_quad_nash.csv")
    data10_q_nash = load_rice_data("rice2023_quad_nash_10asia.csv")

    structure_nash = {
        'Low': {'1Asia': data_q_nash['Low Damage'], '10Asia': data10_q_nash['Low Damage']},
        'Medium': {'1Asia': data_nash['Medium Damage'], '10Asia': data10_nash['Medium Damage']},
        'High': {'1Asia': data_nash['High Damage'], '10Asia': data10_nash['High Damage']},
    }

    structure_negishi = {
        'Low': {'1Asia': data_q_negishi['Low Damage'], '10Asia': data10_q_negishi['Low Damage']},
        'Medium': {'1Asia': data_negishi['Medium Damage'], '10Asia': data10_negishi['Medium Damage']},
        'High': {'1Asia': data_negishi['High Damage'], '10Asia': data10_negishi['High Damage']},
    }

    print("\n--- Tableau des variations (Nash) ---")
    variation_nash = content_table(structure_nash)
    print(tabulate(variation_nash, headers=["Region", "Low Damage", "Medium Damage", "High Damage"], tablefmt="latex"))


    print("\n--- Tableau des variations (Negishi) ---")
    variation_negishi = content_table(structure_negishi)
    print(
        tabulate(variation_negishi, headers=["Region", "Low Damage", "Medium Damage", "High Damage"], tablefmt="latex"))