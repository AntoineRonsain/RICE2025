from pathlib import Path

from tools.tools import *
from tools.compute_st_dev import *
from tools.analysis_tools import *






if __name__ == "__main__":

    BASE_DIR = Path(__file__).resolve().parents[1]
    OUTPUTS_DIR = BASE_DIR / "spatial_consistency/outputs"


    def load_data(filename):
        return read_uncerainties_results(os.path.join(OUTPUTS_DIR, filename))


    d_negishi = load_data("rice2023_negishi.csv")
    d10_negishi = load_data("rice2023_negishi_10asia.csv")
    d_q_negishi = load_data("rice2023_negishi_quad.csv")
    d10_q_negishi = load_data("rice2023_negishi_quad_10asia.csv")

    d_nash = load_data("rice2023_nash.csv")
    d10_nash = load_data("rice2023_nash_10asia.csv")
    d_q_nash = load_data("rice2023_nash_quad.csv")
    d10_q_nash = load_data("rice2023_nash_quad_10asia.csv")

    data_dict = {
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

    variation = []
    for sce in data_dict:
        mu_dict = {}
        region = list(data_dict[sce]['1Asia'].keys())

        for r in region :
            if r =="World":
                pass
            elif "ASIA" in r :
                mu_dict ={}
                for r2 in list(data_dict[sce]['10Asia'].keys()):
                    if "ASIA" in r2:
                        mu_dict[r2] = data_dict[sce]['10Asia'][r2]["Emissions control rate"][:90]
                dev = compute_deviation(compute_mean(mu_dict),
                                        data_dict[sce]['1Asia'][r]["Emissions control rate"][:90])
                variation.append([sce,r,np.round(dev,3)])


    print(tabulate(variation, headers=["Scenario", "Region","Deviation"],tablefmt="latex"))