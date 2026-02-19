import numpy as np
import os
from pathlib import Path
from tabulate import tabulate

from tools.tools import *
from tools.compute_st_dev import *
from tools.analysis_tools import *
import re


def generate_latex_from_dict(data, scenario="Low Damage", years_indices=[0, 3, 6, 16],
                             year_labels=["2020", "2035", "2050", "2100"]):
    """
    Génère le tableau LaTeX à partir d'un dictionnaire structuré.
    data[scenario][region][variable] -> liste de valeurs
    """
    all_regions = [r for r in data[scenario].keys() if r.upper() not in ["WORLD", "GLOBAL", "TOT"]]

    var_name = "Industrial CO2 GtCO2/yr"

    yearly_totals = []
    for idx in years_indices:
        total = sum(data[scenario][reg][var_name][idx] for reg in all_regions)
        yearly_totals.append(total)

    latex = [
        "\\begin{table}[h!]",
        "\\centering",
        f"\\caption{{Regional shares of industrial emissions in \\texttt{{RICE2023-15}} ({scenario} Scenario)}}",
        "\\label{tab:region_emiss_share}",
        "\\begin{tabular}{l" + "c" * len(years_indices) + "}",
        "\\hline",
        "Region & " + " & ".join([f"\\% {y}" for y in year_labels]) + " \\\\",
        "\\hline"
    ]

    for reg in sorted(all_regions):
        row = [reg]
        for i, idx in enumerate(years_indices):
            val_reg = data[scenario][reg][var_name][idx]
            total_world = yearly_totals[i]

            share = (val_reg / total_world * 100) if total_world > 0 else 0
            row.append(f"{int(round(share))} \\%")

        latex.append(" & ".join(row) + " \\\\")

    latex.extend(["\\hline", "\\end{tabular}", "\\end{table}"])

    return "\n".join(latex)



if __name__ == "__main__":
    BASE_DIR = Path(__file__).resolve().parents[1]
    OUTPUTS_DIR = BASE_DIR / "outputs"


    def load_rice_data(filename):
        return read_uncerainties_results(os.path.join(OUTPUTS_DIR, filename))


    data_BAU = load_rice_data("rice2023_BAU_quad.csv")
    print(generate_latex_from_dict(data_BAU))