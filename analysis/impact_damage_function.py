from tools.tools import *
from tools.analysis_tools import *
from tools.compute_st_dev import *


def content_table(data1, data2):
    variation = []
    sce_list = list(data1.keys())
    for sce in sce_list :
        mode_list = list(data1[sce].keys())
        for mode in mode_list :
            region = list(data1[sce][mode].keys())
            region.remove("World")
            for r in region :
                dev = compute_deviation(data1[sce][mode][r]["Emissions control rate"][:90],
                                        data2[sce][mode][r]["Emissions control rate"][:90])
                variation.append([sce, mode, r, dev])
    return variation


if __name__ == "__main__":

    path = os.path.dirname(os.path.dirname(__file__))
    data_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_negishi.csv"))
    data10_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_negishi_10asia.csv"))

    data_nash = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nash.csv"))
    data10_nash = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nash_10asia.csv"))

    data_sigm = {
        'Negishi': {
            '1Asia': data_negishi['Nordhaus'],
            '10Asia': data10_negishi['Nordhaus']},
        'Nash': {
            '1Asia': data_nash['Nordhaus'],
            '10Asia': data10_nash['Nordhaus']},
    }

    data_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nordhaus_negishi.csv"))
    data10_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nordhaus_negishi_10asia.csv"))

    data_nash = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nordhaus_nash.csv"))
    data10_nash = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nordhaus_nash_10asia.csv"))

    data_quad = {
        'Negishi': {
            '1Asia': data_negishi['Nordhaus'],
            '10Asia': data10_negishi['Nordhaus']},
        'Nash': {
            '1Asia': data_nash['Nordhaus'],
            '10Asia': data10_nash['Nordhaus']},
    }


    variation = content_table(data_sigm, data_quad)
    print(tabulate(variation, headers=["Scenario", "Mode", "Region", "Ecart"],tablefmt="latex"))

