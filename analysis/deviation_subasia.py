from tools.tools import *
from tools.compute_st_dev import *
import matplotlib as mpl
import matplotlib.pyplot as plt

def compute_dispersion(mu_dict):
    norm_euclide = compute_norm_euclide(mu_dict)
    region = list(mu_dict.keys())
    sum = 0
    for r in region :
        sum += norm_euclide[r]
    dispersion = sum/len(region)
    return dispersion



if __name__ == "__main__":

    path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    data_negishi = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_negishi.csv"))
    data10_negishi = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_negishi_10asia.csv"))

    data_nash = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nash.csv"))
    data10_nash = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nash_10asia.csv"))

    data_n_negishi = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nordhaus_negishi.csv"))
    data10_n_negishi = read_uncerainties_results(os.path.join(path,"chapter_rice_consistency/spatial_consistency/outputs/rice2023_nordhaus_negishi_10asia.csv"))


    data_n_nash = read_uncerainties_results(
        os.path.join(path, "chapter_rice_consistency/spatial_consistency/outputs/rice2023_nordhaus_nash.csv"))
    data10_n_nash = read_uncerainties_results(
        os.path.join(path, "chapter_rice_consistency/spatial_consistency/outputs/rice2023_nordhaus_nash_10asia.csv"))

    data_dict = {
        'Non-Cooperative + Low Damage': {
            '1Asia': data_n_nash['Nordhaus'],
            '10Asia': data10_n_nash['Nordhaus']},
        'Non-Cooperative + Middle Damage': {
            '1Asia': data_nash['Middle-Damage'],
            '10Asia': data10_nash['Middle-Damage']},
        'Non-Cooperative + Strong Damage': {
            '1Asia': data_nash['Standard'],
            '10Asia': data10_nash['Standard']},
        'Cooperative + Low Damage': {
            '1Asia': data_n_negishi['Nordhaus'],
            '10Asia': data10_n_negishi['Nordhaus']},
        'Cooperative + Middle Damage': {
            '1Asia': data_negishi['Middle-Damage'],
            '10Asia': data10_negishi['Middle-Damage']},
        'Cooperative + Strong Damage': {
            '1Asia': data_negishi['Standard'],
            '10Asia': data10_negishi['Standard']},
    }

    dispersion = []
    for sce in data_dict:
        mu_dict = {}
        region = list(data_dict[sce]['10Asia'].keys())
        for r in region :
            if "ASIA" in r :
                mu_dict[r] = data_dict[sce]['10Asia'][r]["Emissions control rate"][:90]
        dispersion.append([sce,compute_dispersion(mu_dict)])

    print(tabulate(dispersion, headers=["Scenario", "Dispersion"]))

    N = 90
    year = [2020+i*5 for i in range(N)]
    limmiu2070 = 1
    limmiu2120 = 1.1
    delmiumax = 0.12
    miuup0 = .05
    miuup = np.ones(N) * miuup0
    miuup[1] = .10
    for t in range(2, N):
        if t <= 7:
            miuup[t] = delmiumax * t
        elif t <= 10:
            miuup[t] = 0.85 + .05 * (t - 7)
        elif t <= 19:
            miuup[t] = limmiu2070
        else:
            miuup[t] = limmiu2120

    nb_rows = 3
    nb_cols = 2
    mpl.rc('xtick', labelsize=15)
    mpl.rc('ytick', labelsize=15)
    fig, axs = plt.subplots(nb_rows, nb_cols)

    i = 0
    j = 1

    noms_colonnes = ["Cooperative", "Non-Cooperative"]
    noms_lignes = ["Low damages", "Middle damages", "Strong damages"]
    for sce in data_dict.keys():
        if i == 3 :
            i = 0
            j = 0
        axs[i, j].plot(year, miuup, color="black", lw=3, label="Maximum")
        axs[i, j].plot(year, data_dict[sce]['1Asia']['ASIA']["Emissions control rate"][:90], color = 'blue', label="Asia")
        axs[i, j].plot(year, data_dict[sce]['10Asia']['ASIA0']["Emissions control rate"][:90],color = 'blue',  linestyle="--",
                 label="mean sub-Asia")
        i+=1
    axs[0, 0].legend(bbox_to_anchor=(3, 1), fontsize=15)
    for j, nom_colonne in enumerate(noms_colonnes):
            axs[0, j].set_title(nom_colonne, fontsize=20, pad=20)
    for i, nom_ligne in enumerate(noms_lignes):
        if i < nb_rows:
            axs[i, 0].set_ylabel(nom_ligne, fontsize=20, labelpad=20)
    plt.show()

