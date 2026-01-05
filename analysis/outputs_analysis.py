import matplotlib.pyplot as plt
import numpy as np
from tools.analysis_tools import *
from tools.tools import *
import os


def content_table(data, region):
    share = []
    sum2020 = 0
    sum2035 = 0
    sum2050 = 0
    sum2100 = 0
    for r in region :
        sum2020 +=  data[r]["eind"][0]
        sum2035 +=  data[r]["eind"][3]
        sum2050 +=  data[r]["eind"][7]
        sum2100 +=  data[r]["eind"][16]

    for r in region:
        share.append([r,str(int(100* data[r]["eind"][0]/sum2020))+' %',
                      str(int(100* data[r]["eind"][3]/sum2035))+' %',
                      str(int(100* data[r]["eind"][7]/sum2050))+' %',
                      str(int(100* data[r]["eind"][16]/sum2100))+' %'])
    return share



if __name__ == "__main__":

    path = os.path.dirname(os.path.dirname(__file__))
    data = read_results(os.path.join(path,"spatial_consistency/outputs/rice2023_bau.csv"))
    data = data["Standard"]

    regions = list(data.keys())
    regions.remove('World')
    plot_param = plot_param_for_region(regions)
    year = [2020 + i * 5 for i in range(101)]


    share = content_table(data, regions)
    print(tabulate(share, headers=["Region", "% 2020", "% 2035", "% 2050", "% 2100"],tablefmt="latex"))


    fig = plt.figure()
    ax = fig.add_subplot(111)
    for r in regions:
        plt.plot(year, np.array(data[r]["eind"]),
                 color=plot_param[r]['color'], linestyle=plot_param[r]["style"], label=r, linewidth=1)
    plt.xlabel('Time', fontsize="20")
    plt.ylabel('Industrial emissions', fontsize="20")
    for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
        tickLabel.set_fontsize(15)
    plt.grid(axis='y')
    plt.grid(color='black', linestyle='-', linewidth=1)
    plt.legend(fontsize=20)
    plt.show()
    
