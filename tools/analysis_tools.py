
def get_matplotlib_color():
    color ={'tab:blue': '#1f77b4',
          'tab:orange': '#ff7f0e',
          'tab:green': '#2ca02c',
          'tab:red': '#d62728',
          'tab:purple': '#9467bd',
          'tab:brown': '#8c564b',
          'tab:pink': '#e377c2',
          'tab:gray': '#7f7f7f',
          'tab:olive': '#bcbd22',
          'tab:cyan': '#17becf'}
    return color


def plot_param_for_region(list_region):
    color_dict = get_matplotlib_color()
    color_list = [color_dict[i] for i in color_dict.keys()]
    style_list = ['-','--',':','-.']
    param_plot = {}
    for i in range(len(list_region)):
         param_plot[list_region[i]] = {
               'color' : color_list[i % len(color_list)],
                'style' : style_list[i // len(color_list)],
         }
    return param_plot

def compute_deviation(var,ref):
    sum = 0
    count = 0
    for t in range(len(var)):
        sum += (var[t] - ref[t])
        count += 1
    return sum/count