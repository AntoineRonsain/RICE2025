import matplotlib.pyplot as plt
import numpy as np
from tools.analysis_tools import *
from tools.tools import *
import os





if __name__ == "__main__":

    path = os.path.dirname(os.path.dirname(__file__))
    data = read_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nash.csv"))
    data = data["High Damage"]

    regions = list(data.keys())
    regions.remove('World')
    plot_param = plot_param_for_region(regions)
    year = [2020 + i * 5 for i in range(101)]




    fig = plt.figure()
    ax = fig.add_subplot(111)
    for r in regions:
        plt.plot(year, np.array(data[r]["Saving rate"]),
                 color=plot_param[r]['color'], linestyle=plot_param[r]["style"], label=r, linewidth=1)
    plt.xlabel('Time', fontsize="20")
    plt.ylabel('Industrial emissions', fontsize="20")
    for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
        tickLabel.set_fontsize(15)
    plt.grid(axis='y')
    plt.grid(color='black', linestyle='-', linewidth=1)
    plt.legend(fontsize=20)
    plt.show()