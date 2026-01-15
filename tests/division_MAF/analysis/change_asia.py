import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from pathlib import Path
from tools.tools import read_uncerainties_results
from tabulate import tabulate
import matplotlib as mpl


def compute_mean(mu_dict):
    mean_mu = []
    region = list(mu_dict.keys())
    for t in range(len(mu_dict[region[0]])):
        sum = 0
        count = 0
        for r in region:
            sum += mu_dict[r][t]
            count += 1
        mean = sum / count
        mean_mu.append(mean)
    return mean_mu


def compute_norm_euclide(mu_dict):
    mean_mu = compute_mean(mu_dict)
    region = list(mu_dict.keys())
    norm_euclide = {}
    for r in region :
        sum = 0
        for t in range(len(mu_dict[r])):
            sum += (mean_mu[t] - mu_dict[r][t])**2
        sum = np.sqrt(sum)
        norm_euclide[r] = sum
    return norm_euclide

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

    outputs_dir = os.path.dirname(os.path.dirname((os.path.dirname((os.path.dirname(__file__))))))

    def read_file(filename, output_path = outputs_dir):
        output_path = os.path.join(output_path, "tests\saving_rate\output")
        return read_uncerainties_results(os.path.join(output_path, filename))


    data_negishi = read_file("rice2023_negishi.csv")
    data10_negishi = read_file("rice2023_negishi_10asia.csv")
    data_n_negishi = read_file("rice2023_negishi_quad.csv")
    data10_n_negishi = read_file("rice2023_negishi_quad_10asia.csv")

    data_nash = read_file("rice2023_nash.csv")
    data10_nash = read_file("rice2023_nash_10asia.csv")
    data_n_nash = read_file("rice2023_nash_quad.csv")
    data10_n_nash = read_file("rice2023_nash_quad_10asia.csv")


    data_dict = {
        'Non-Cooperative + Low Damage': {
            '1Asia': data_n_nash['Low Damage'],
            '10Asia': data10_n_nash['Low Damage']},
        'Non-Cooperative + Middle Damage': {
            '1Asia': data_nash['Medium Damage'],
            '10Asia': data10_nash['Medium Damage']},
        'Non-Cooperative + Strong Damage': {
            '1Asia': data_nash['High Damage'],
            '10Asia': data10_nash['High Damage']},
        'Cooperative + Low Damage': {
            '1Asia': data_n_negishi['Low Damage'],
            '10Asia': data10_n_negishi['Low Damage']},
        'Cooperative + Middle Damage': {
            '1Asia': data_negishi['Medium Damage'],
            '10Asia': data10_negishi['Medium Damage']},
        'Cooperative + Strong Damage': {
            '1Asia': data_negishi['High Damage'],
            '10Asia': data10_negishi['High Damage']},
    }



    dispersion = []
    for sce in data_dict:
        mu_dict = {}
        region = list(data_dict[sce]['10Asia'].keys())
        for r in region :
            if "ASIA" in r :
                mu_dict[r] = data_dict[sce]['10Asia'][r]["Emissions control rate"][:81]
        dispersion.append([sce,compute_dispersion(mu_dict)])

    print(tabulate(dispersion, headers=["Scenario", "Dispersion"]))

    N = 81
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
        axs[i, j].plot(year, data_dict[sce]['1Asia']['ASIA']["Emissions control rate"][:81], color = 'blue', label="Asia")
        axs[i, j].plot(year, data_dict[sce]['10Asia']['ASIA0']["Emissions control rate"][:81],color = 'blue',  linestyle="--",
                 label="mean sub-Asia")
        i+=1
    axs[0, 0].legend(bbox_to_anchor=(3, 1), fontsize=15)
    for j, nom_colonne in enumerate(noms_colonnes):
            axs[0, j].set_title(nom_colonne, fontsize=20, pad=20)
    for i, nom_ligne in enumerate(noms_lignes):
        if i < nb_rows:
            axs[i, 0].set_ylabel(nom_ligne, fontsize=20, labelpad=20)
    plt.show()

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
        axs[i, j].plot(year, data_dict[sce]['1Asia']['ASIA']["Saving rate"][:81], color = 'blue', label="Asia")
        axs[i, j].plot(year, data_dict[sce]['10Asia']['ASIA0']["Saving rate"][:81],color = 'blue',  linestyle="--",
                 label="mean sub-Asia")
        i+=1
    axs[0, 0].legend(bbox_to_anchor=(3, 1), fontsize=15)
    for j, nom_colonne in enumerate(noms_colonnes):
            axs[0, j].set_title(nom_colonne, fontsize=20, pad=20)
    for i, nom_ligne in enumerate(noms_lignes):
        if i < nb_rows:
            axs[i, 0].set_ylabel(nom_ligne, fontsize=20, labelpad=20)
    plt.show()



