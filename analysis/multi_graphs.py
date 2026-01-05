import matplotlib.pyplot as plt
from tools.analysis_tools import *
from tools.tools import *
import matplotlib as mpl
from tools.compute_st_dev import *

if __name__ == "__main__":

    path = os.path.dirname(os.path.dirname(__file__))
    data = read_results(os.path.join(path, "spatial_consistency/outputs/rice2023_negishi.csv"))
    data_n = read_results(os.path.join(path, "spatial_consistency/outputs/rice2023_nordhaus_negishi.csv"))

    data["Nordhaus"] = data_n["Nordhaus"]

    corr = {"Nordhaus": "Low Damage",
            "Middle-Damage": "Middle Damage",
            "Standard": "High Damage",
            }

    sce = list(corr.keys())
    regions = list(data[sce[0]].keys())
    regions.remove('World')
    plot_param = plot_param_for_region(regions)

    N = 101
    year = [2020 + i * 5 for i in range(N)]
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

    mu_dict= {}
    for s in sce:
        mu_dict[s] = {}
        for r in regions:
            mu_dict[s][r] = data[s][r]["Emissions control rate"][:90]

    nb_rows = 2
    nb_cols = 2
    mpl.rc('xtick', labelsize=15)
    mpl.rc('ytick', labelsize=15)
    fig, axs = plt.subplots(nb_rows, nb_cols)
    for i in range(nb_rows):
        for j in range(nb_cols):
            key = j * nb_cols + i
            if key < len(sce):
                dispersion = compute_dispersion(mu_dict[sce[key]])
                axs[j, i].plot(year[:37], miuup[:37], linewidth=2, color='black', label="Maximum")
                for r in regions:
                    axs[j, i].plot(year[:37], data[sce[key]][r]["Emissions control rate"][:37],
                                   color=plot_param[r]['color'], linestyle=plot_param[r]["style"], label=r, linewidth=1)
                axs[j, i].set_title(
                    f'$\epsilon = {np.round(dispersion, 3)}$',
                    fontsize=35)
    axs[j, i].remove()
    axs[j, i - 1].legend(ncol=2, bbox_to_anchor=(2, 1), fontsize=20)
    plt.show()

    nb_rows = 1
    nb_cols = 2
    fig, (axs1, axs2) = plt.subplots(nb_rows, nb_cols)
    for s in sce:
        gdp = 0
        pop = 0
        for r in regions:
            gdp += np.array(data[s][r]["Output, net net trill 2019$"])
            pop += np.array(data[s][r]["Population (exogenous)"])
        axs1.plot(year[:37], gdp[:37] * 1000 / pop[:37], label=corr[s])
    axs1.set_xlabel('Time', fontsize="25")
    axs1.set_ylabel('GDP per capita (in 000 $ /hab)', fontsize="25")
    for s in sce:
        axs2.plot(year[:37], data[s]['World']["Atmospheric temperature (deg c above preind)"][:37], label=corr[s])
    axs2.set_xlabel('Time', fontsize="25")
    axs2.set_ylabel('Increase in atmospheric temperature (in °C)', fontsize="25")
    axs1.legend(fontsize=25)
    for ax in fig.get_axes():
        for tickLabel in ax.get_xticklabels() + ax.get_yticklabels():
            tickLabel.set_fontsize(25)
    plt.show()

    nb_rows = 2
    nb_cols = 2
    mpl.rc('xtick', labelsize=15)
    mpl.rc('ytick', labelsize=15)
    fig, axs = plt.subplots(nb_rows, nb_cols)
    for i in range(nb_rows):
        for j in range(nb_cols):
            key = j * nb_cols + i
            if key < len(sce):
                dispersion = compute_dispersion(mu_dict[sce[key]])
                axs[j, i].plot(year[:37], miuup[:37], linewidth=2,color = 'black', label = "Maximum")
                for r in regions:
                    axs[j, i].plot(year[:37], data[sce[key]][r]["Emissions control rate"][:37],
                                   color = plot_param[r]['color'],linestyle = plot_param[r]["style"], label = r, linewidth=1)
                axs[j, i].set_title(f'Emissions control rate with {corr[sce[key]]} ($\epsilon = {np.round(dispersion,3)}$)',fontsize = 20)
    axs[j, i].remove()
    axs[j, i-1].legend(ncol=2,bbox_to_anchor=(2, 1), fontsize=20)
    plt.show()

    nb_rows = 1
    nb_cols = 2
    fig, (axs1, axs2) = plt.subplots(nb_rows, nb_cols)
    for s in sce :
        gdp = 0
        pop = 0
        for r in regions:
            gdp += np.array(data[s][r]["Output, net net trill 2019$"])
            pop += np.array(data[s][r]["Population (exogenous)"])
        axs1.plot(year[:37] , gdp[:37] * 1000 / pop[:37], label = corr[s])
    axs1.set_xlabel('Time', fontsize="25")
    axs1.set_ylabel('GDP per capita (in 000 $ /hab)', fontsize="25")
    for s in sce :
        axs2.plot(year[:37] , data[s]['World']["Atmospheric temperature (deg c above preind)"][:37] , label = corr[s])
    axs2.set_xlabel('Time', fontsize="25")
    axs2.set_ylabel('Increase in atmospheric temperature (in °C)', fontsize="25")
    axs1.legend(fontsize=20)
    plt.show()

