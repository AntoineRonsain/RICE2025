import matplotlib.pyplot as plt
from tools.analysis_tools import *
from tools.tools import *
import matplotlib as mpl
from tools.compute_st_dev import *

if __name__ == "__main__":

    path = os.path.dirname(os.path.dirname(__file__))
    data = read_results(os.path.join(path, "spatial_consistency/outputs/rice2023_negishi.csv"))
    data = data['High Damage']


    regions = list(data.keys())
    regions.remove('World')
    plot_param = plot_param_for_region(regions)

    t = np.array([2020+i*5 for i in range(101)])
    fig = plt.figure()
    ax = fig.add_subplot(111)
    for r in regions:
        plt.plot(t, data[r]['Abatement/0utput'],color=plot_param[r]['color'], linestyle=plot_param[r]["style"], linewidth=2, label=r)
    for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
        tickLabel.set_fontsize(20)
    plt.xlabel('Atmospheric temperature (in °C)', fontsize="20")
    plt.ylabel('Damages (in % of GDP)', fontsize="20")
    plt.grid(axis='y')
    plt.legend(fontsize="20")
    plt.grid(color='black', linestyle='-', linewidth=1)
    ax.legend(fontsize="20", loc='upper left')
    plt.show()