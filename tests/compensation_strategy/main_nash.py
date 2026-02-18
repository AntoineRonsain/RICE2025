from tools.nash_files import *
import os
import numpy as np
from pathlib import Path
from tools.tools import read_uncerainties_results
from tools.analysis_tools import plot_param_for_region


# --- FONCTIONS UTILITAIRES ---

def load_data(filename):
    """Fonction utilitaire pour charger les résultats"""
    file_path = os.path.join(OUTPUTS_DIR, filename)
    return read_uncerainties_results(file_path)


def extract_filtered_data(data_source, scenarios_list, regions_list):
    """
    Extrait Saving Rate (s) et Emissions Control (mu) pour des scénarios
    et régions spécifiques.
    """
    s_dict = {}
    mu_dict = {}

    for sce in scenarios_list:
        if sce in data_source:
            s_dict[sce] = {}
            mu_dict[sce] = {}
            for reg in regions_list:
                if reg in data_source[sce]:
                    # Extraction Saving Rate
                    if "Saving rate" in data_source[sce][reg]:
                        s_dict[sce][reg] = data_source[sce][reg]["Saving rate"]
                    # Extraction Emissions Control Rate
                    if "Emissions control rate" in data_source[sce][reg]:
                        mu_dict[sce][reg] = data_source[sce][reg]["Emissions control rate"]
    return mu_dict, s_dict


def write_scenario_file(filename, s_data, mu_data):
    """
    Ecrit un fichier .txt avec le format s.fx("t","n") = valeur;
    """

    BASE_DIR = Path(__file__).resolve().parents[0]
    OUTPUTS_DIR = BASE_DIR / "type_files"
    filepath = os.path.join(OUTPUTS_DIR, filename)

    with open(filepath, 'w') as f:

        f.write("* --- Saving Rate (s) ---\n")
        for reg, values in s_data.items():
            for t, val in enumerate(values):
                # t+1 car l'indice commence souvent à 1 en GAMS/modélisation
                # .4f pour limiter à 4 décimales (optionnel, pour la lisibilité)
                f.write(f's.fx("{t + 1}","{reg}") = {val:.5f};\n')

        f.write("\n")

        f.write("* --- Emissions Control Rate (mu) ---\n")
        for reg, values in mu_data.items():
            for t, val in enumerate(values):
                f.write(f'miu.fx("{t + 1}","{reg}") = {val:.5f};\n')


# --- MAIN ---

if __name__ == '__main__':

    BASE_DIR = Path(__file__).resolve().parents[2]
    OUTPUTS_DIR = BASE_DIR / "spatial_consistency/outputs"

    # 1. Chargement
    d_nash = load_data("rice2023_nash.csv")
    d_q_nash = load_data("rice2023_nash_quad.csv")
    d10_nash = load_data("rice2023_nash_10asia.csv")
    d10_q_nash = load_data("rice2023_nash_quad_10asia.csv")

    # 2. Listes
    region_1asia = ["USA", "RUS", "JAP", "CAN", "OAB", "EU", "CHN", "IND", "BRZ", "SAF", "OEU", "REF", "MAF", "LAM"]
    region_10asia = ["ASIA0", "ASIA1", "ASIA2", "ASIA3", "ASIA4", "ASIA5", "ASIA6", "ASIA7", "ASIA8", "ASIA9"]

    scenario_std = ["High Damage", "Medium Damage"]
    scenario_quad = ["Low Damage"]

    # 3. Extraction
    mu_nash, s_nash = extract_filtered_data(d_nash, scenario_std, region_1asia)
    mu_d10, s_d10 = extract_filtered_data(d10_nash, scenario_std, region_10asia)
    mu_nash_q, s_nash_q = extract_filtered_data(d_q_nash, scenario_quad, region_1asia)
    mu_d10_q, s_d10_q = extract_filtered_data(d10_q_nash, scenario_quad, region_10asia)


    sce = "High Damage"
    s_combined_high = {**s_nash.get(sce, {}), **s_d10.get(sce, {})}
    mu_combined_high = {**mu_nash.get(sce, {}), **mu_d10.get(sce, {})}
    if s_combined_high:
        write_scenario_file("High_Damage_params.txt", s_combined_high, mu_combined_high)

    sce = "Medium Damage"
    s_combined_med = {**s_nash.get(sce, {}), **s_d10.get(sce, {})}
    mu_combined_med = {**mu_nash.get(sce, {}), **mu_d10.get(sce, {})}
    if s_combined_med:
        write_scenario_file("Medium_Damage_params.txt", s_combined_med, mu_combined_med)

    sce = "Low Damage"
    s_combined_low = {**s_nash_q.get(sce, {}), **s_d10_q.get(sce, {})}
    mu_combined_low = {**mu_nash_q.get(sce, {}), **mu_d10_q.get(sce, {})}
    if s_combined_low:
        write_scenario_file("Low_Damage_params.txt", s_combined_low, mu_combined_low)
