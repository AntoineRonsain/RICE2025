import matplotlib.pyplot as plt
import numpy as np
from tools.tools import *
from tools.analysis_tools import *
from tools.compute_st_dev import *
import seaborn as sns


if __name__ == "__main__":

    path = os.path.dirname(os.path.dirname(__file__))
    data_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_negishi.csv"))
    data10_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_negishi_10asia.csv"))

    data_nash = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nash.csv"))
    data10_nash = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nash_10asia.csv"))

    data_n_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nordhaus_negishi.csv"))
    data10_n_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nordhaus_negishi_10asia.csv"))


    data_n_nash = read_uncerainties_results(
        os.path.join(path, "spatial_consistency/outputs/rice2023_nordhaus_nash.csv"))
    data10_n_nash = read_uncerainties_results(
        os.path.join(path, "spatial_consistency/outputs/rice2023_nordhaus_nash_10asia.csv"))

    data_dict = {
        'Negishi + Low Damage': {
            '1Asia': data_n_negishi['Nordhaus'],
            '10Asia': data10_n_negishi['Nordhaus']},
        'Negishi + Middle Damage': {
            '1Asia': data_negishi['Middle-Damage'],
            '10Asia': data10_negishi['Middle-Damage']},
        'Negishi + Strong Damage': {
            '1Asia': data_negishi['Standard'],
            '10Asia': data10_negishi['Standard']},
        'Nash + Low Damage': {
            '1Asia': data_n_nash['Nordhaus'],
            '10Asia': data10_n_nash['Nordhaus']},
        'Nash + Middle Damage': {
            '1Asia': data_nash['Middle-Damage'],
            '10Asia': data10_nash['Middle-Damage']},
        'Nash + Strong Damage': {
            '1Asia': data_nash['Standard'],
            '10Asia': data10_nash['Standard']}
    }

    for m in data_dict.keys():
        for asia in data_dict[m].keys():
            for r in data_dict[m][asia].keys():
                for p in data_dict[m][asia][r].keys():
                    data_dict[m][asia][r][p] = data_dict[m][asia][r][p][:90]


    data = {
        'region' :[],
        'value' : [],
        'solver': [],
        'damage' : [],
    }


    for m in data_dict.keys() :
        for r in data_dict[m]['1Asia'].keys():
            if r != "World" and r != "ASIA":
                emission_control = (np.array(data_dict[m]['10Asia'][r]["Emissions control rate"][:90])\
                                   - np.array(data_dict[m]['1Asia'][r]["Emissions control rate"][:90]))
                for t in emission_control:
                    data['region'].append(r)
                    data['value'].append(t)
                    solver, damage = m.split(' + ')
                    data['solver'].append(solver)
                    data['damage'].append(damage)

    df = pd.DataFrame(data)
    sns.boxplot(x='region', y='value', data=df[df['solver'] == 'Negishi'], hue='damage')
    plt.title('Change in Emission control for other regions (Cooperative)',fontsize= 35)
    plt.legend(bbox_to_anchor=(1.05, 1),fontsize= 20,loc='upper left')
    plt.xlabel('', fontsize="25")
    plt.ylabel('', fontsize="25")
    for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
        tickLabel.set_fontsize(25)
    plt.show()


    df = pd.DataFrame(data)
    sns.boxplot(x='region', y='value', data=df[df['solver'] == 'Nash'], hue='damage')
    plt.title('Change in Emission control for other regions (Non-cooperative)',fontsize= 35)
    plt.legend(bbox_to_anchor=(1.05, 1),fontsize= 20,loc='upper left')
    plt.xlabel('', fontsize="25")
    plt.ylabel('', fontsize="25")
    for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
        tickLabel.set_fontsize(25)
    plt.show()

    data = {
        'region' :[],
        'value' : [],
        'solver': [],
        'damage' : [],
    }

    for m in data_dict.keys() :

            emission_control = (np.array(data_dict[m]['10Asia']['ASIA0']["Emissions control rate"][:90])\
                               - np.array(data_dict[m]['1Asia']['ASIA']["Emissions control rate"][:90]))
            for t in emission_control:
                data['region'].append('mean Sub-Asia / Asia')
                data['value'].append(t)
                solver, damage = m.split(' + ')
                data['solver'].append(solver)
                data['damage'].append(damage)


    df = pd.DataFrame(data)
    fig, axes = plt.subplots(nrows=1, ncols=2,sharey=True)
    sns.boxplot(
        data=df[df['solver'] == 'Negishi'],
        x='region',
        y='value',
        hue = 'damage',
        ax=axes[0]
    )
    axes[0].set_title('Cooperative',fontsize=20 )
    axes[0].set_ylabel('')
    axes[0].set_xlabel('')


    sns.boxplot(
        data=df[df['solver'] == 'Nash'],
        x='region',
        y='value',
        hue = 'damage',
        ax=axes[1]
    )
    axes[1].set_title('Non-cooperative',fontsize=20 )
    axes[1].set_ylabel('')
    axes[1].set_xlabel('')
    axes[1].set_xlabel('')
    axes[1].get_legend().remove()
    axes[0].legend(fontsize= 15)

    for ax in axes:
        ax.tick_params(axis='both', which='major', labelsize=14)
        ax.tick_params(axis='x')
        # ax.set_xlabel('Région', fontsize=16)
    plt.show()



    data = {
        'T' :[],
        'co2' : [],
        'gpdc' : [],
        'damage' : [],
        'solver' : []
    }
    for m in data_dict.keys() :
        delta_tatm = np.array(data_dict[m]['10Asia']['World']["Atmospheric temperature (deg c above preind)"]) \
                        - np.array(data_dict[m]['1Asia']['World']["Atmospheric temperature (deg c above preind)"])
        delta_eco2 = np.array(data_dict[m]['10Asia']['World']["Total CO2 Emissions, GTCO2/year"]) \
                        - np.array(data_dict[m]['1Asia']['World']["Total CO2 Emissions, GTCO2/year"])

        yy = 0
        yy10 = 0
        pop = 0
        for r in data_dict[m]['1Asia'].keys():
            if r != "World":
                yy += np.array(data_dict[m]['1Asia'][r]["Output, net net trill 2019$"])
                pop += np.array(data_dict[m]['1Asia'][r]["Population (exogenous)"])
        for r in data_dict[m]['10Asia'].keys():
            if r != "World":
                yy10 += np.array(data_dict[m]['10Asia'][r]["Output, net net trill 2019$"])
        delta_y = (yy10 - yy) / yy


        for t in range(len(delta_tatm)):
            data['T'].append(delta_tatm[t])
            data['co2'].append(delta_eco2[t])
            data['gpdc'].append(delta_y[t])
            solver, damage = m.split(' + ')
            if solver == 'Negishi':
                data['solver'].append('Cooperative')
            else:
                data['solver'].append('Non-cooperative')
            data['damage'].append(damage)


    df = pd.DataFrame(data)
    fig, axes = plt.subplots(nrows=1, ncols=2)
    sns.boxplot(
        data=df,
        x='solver',
        y='gpdc',
        hue = 'damage',
        ax=axes[0]
    )
    axes[0].set_title('GDP (relative change)',fontsize=20)
    axes[0].set_ylabel('')
    axes[0].set_xlabel('')
    axes[0].get_legend().remove()


    sns.boxplot(
        data=df,
        x='solver',
        y='T',
        hue = 'damage',
        ax=axes[1]
    )
    axes[1].set_title('Increase in temperature (in °C)',fontsize=20 )
    axes[1].set_ylabel('')
    axes[1].set_xlabel('')
    axes[1].set_xlabel('')
    axes[1].legend(fontsize= 15)

    for ax in axes:
        # Augmente la taille des graduations sur les deux axes
        ax.tick_params(axis='both', which='major', labelsize=14)

        # Fait pivoter les étiquettes de l'axe X de 90 degrés pour éviter la superposition
        ax.tick_params(axis='x')

    plt.show()
