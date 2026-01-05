import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from gini import *


if __name__ == '__main__':

    path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    path = os.path.join(path, "climate_damage/outputs/rice2023_bau.csv")
    gini,lorenz = compute_gini(path, return_Lorenz=True, sce= "Medium", python = True)
    gini_optimistic,lorenz_optimistic = compute_gini(path, return_Lorenz=True, sce= "Optimistic", python = True)
    gini_pessimistic,lorenz_pessimistic = compute_gini(path, return_Lorenz=True, sce= "Pessimistic", python = True)




    fig, ax = plt.subplots()
    ax = plt.axes(xlim=(0,1), ylim=(0, 1))
    line1, = ax.plot([], [], lw=2, color = "black")
    line2, = ax.plot([], [], lw=2)
    line3, = ax.plot([], [], lw=2)
    line4, = ax.plot([], [], lw=2)
    L = plt.legend(loc=1)


    def animate(i):
        line1.set_data(lorenz[i]["Cumulative share pop"], lorenz[i]["Cumulative share pop"])
        line2.set_data(lorenz[i]["Cumulative share pop"], lorenz[i]["Cumulative share gdp"])
        line3.set_data(lorenz_pessimistic[i]["Cumulative share pop"], lorenz_pessimistic[i]["Cumulative share gdp"])
        line4.set_data(lorenz_optimistic[i]["Cumulative share pop"], lorenz_optimistic[i]["Cumulative share gdp"])

        lab = "GINI BAU-Optimistic = " + str(round(gini_optimistic[i],3))
        line4.set_label(lab)  # Update label each at frame
        lab = "GINI BAU-Standard = " + str(round(gini[i],3))
        line2.set_label(lab)  # Update label each at frame
        lab = "GINI BAU-Pessimistic = " + str(round(gini_pessimistic[i],3))
        line3.set_label(lab)  # Update label each at frame
        ax.legend(loc=1)
        ax.set_title('Lorenz curve in '+str(int(2020 + 5 * i)))
        return line1,line2,line3, line4

    anim = FuncAnimation(fig, animate, frames=100, interval=200, repeat=False)
    plt.show()