import numpy as np
from tools.tools import *
from tools.compute_st_dev import *
from tools.analysis_tools import *



def compute_deviation(var,ref):
    sum = 0
    count = 0
    for t in range(len(var)):
        sum += (var[t] - ref[t])
        count += 1
    return sum/count

def content_table(data_dict):
    variation = []
    sce_list = list(data_dict.keys())
    region = list(data_dict[sce_list[0]]['1Asia'].keys())
    region.remove("World")
    for r in region :
        buffer = [r]
        for sce in sce_list:
            if "ASIA" in r :
                mu_dict ={}
                for r2 in list(data_dict[sce]['10Asia'].keys()):
                    if "ASIA" in r2:
                        mu_dict[r2] = data_dict[sce]['10Asia'][r2]["Emissions control rate"][:90]
                dev = compute_deviation(compute_mean(mu_dict),
                                        data_dict[sce]['1Asia'][r]["Emissions control rate"][:90])
                buffer.append(np.round(dev,3))
            else:
                dev = compute_deviation(data_dict[sce]['10Asia'][r]["Emissions control rate"][:90],
                                        data_dict[sce]['1Asia'][r]["Emissions control rate"][:90])
                buffer.append(np.round(dev,3))
        variation.append(buffer)
    return variation

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



    data_nash = {
        'Low': {
            '1Asia': data_n_nash['Nordhaus'],
            '10Asia': data10_n_nash['Nordhaus']},
        'Middle': {
            '1Asia': data_nash['Middle-Damage'],
            '10Asia': data10_nash['Middle-Damage']},
        'Strong': {
            '1Asia': data_nash['Standard'],
            '10Asia': data10_nash['Standard']},
    }

    data_negishi = {
        'Low': {
            '1Asia': data_n_negishi['Nordhaus'],
            '10Asia': data10_n_negishi['Nordhaus']},
        'Middle': {
            '1Asia': data_negishi['Middle-Damage'],
            '10Asia': data10_negishi['Middle-Damage']},
        'Strong': {
            '1Asia': data_negishi['Standard'],
            '10Asia': data10_negishi['Standard']},
    }


    variation = content_table(data_nash)
    print(tabulate(variation, headers=["Region", "Low Damage", "Middle Damage", "High Damage"],tablefmt="latex"))