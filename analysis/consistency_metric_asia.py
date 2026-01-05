import numpy as np
from tools.tools import *
from tools.compute_st_dev import *
from tools.analysis_tools import *





if __name__ == "__main__":

    path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    data_negishi = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_negishi.csv"))
    data10_negishi = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_negishi_10asia.csv"))

    data_nash = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nash.csv"))
    data10_nash = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nash_10asia.csv"))


    data_n_negishi = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nordhaus_negishi.csv"))
    data10_n_negishi = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nordhaus_negishi_10asia.csv"))

    data_n_nash = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nordhaus_nash.csv"))
    data10_n_nash = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nordhaus_nash_10asia.csv"))

    data_dict = {
        'Nash + Low Damage': {
            '1Asia': data_n_nash['Nordhaus'],
            '10Asia': data10_n_nash['Nordhaus']},
        'Nash + Middle Damage': {
            '1Asia': data_nash['Middle-Damage'],
            '10Asia': data10_nash['Middle-Damage']},
        'Nash + Strong Damage': {
            '1Asia': data_nash['Standard'],
            '10Asia': data10_nash['Standard']},
        'Negishi + Low Damage': {
            '1Asia': data_n_negishi['Nordhaus'],
            '10Asia': data10_n_negishi['Nordhaus']},
        'Negishi + Middle Damage': {
            '1Asia': data_negishi['Middle-Damage'],
            '10Asia': data10_negishi['Middle-Damage']},
        'Negishi + Strong Damage': {
            '1Asia': data_negishi['Standard'],
            '10Asia': data10_negishi['Standard']},
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