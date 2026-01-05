import matplotlib.pyplot as plt
import numpy as np
from tools.tools import *


def get_full_results(data):
    pop = 0
    gdp = 0
    region = list(data.keys())

    for r in region:
        pop += np.array(data[r]["Population (exogenous)"])
        gdp += np.array(data[r]["Output, net net trill 2019$"])

    for r in region:
        data[r]["Share population"] = np.array(data[r]["Population (exogenous)"]) / pop
        data[r]["Share gdp"] = np.array(data[r]["Output, net net trill 2019$"]) / gdp
        data[r]["gdpc"] = np.array(data[r]["Output, net net trill 2019$"]) / np.array(
            data[r]["Population (exogenous)"])
    return data


def full_results_to_df(data):
    data_dict = {
        "region": [],
        "year": [],
        "Share gdp": [],
        "Share population": [],
        "gdpc": []
    }
    region = list(data.keys())
    year = len(data[region[0]]["Population (exogenous)"])
    for r in region:
        for y in range(year):
            data_dict["region"].append(r)
            data_dict["year"].append(y)
            data_dict["Share gdp"].append(data[r]["Share gdp"][y])
            data_dict["Share population"].append(data[r]["Share population"][y])
            data_dict["gdpc"].append(data[r]["gdpc"][y])
    df = pd.DataFrame(data_dict)
    return df

def compute_lorenz_curve(df):

    lorenz = {}
    year = np.array(list(df['year']))
    year = np.unique(year)

    for y in year:
        sub_df = df[df["year"] == y]
        sub_df = sub_df.sort_values(by='gdpc')

        share_gdp = list(sub_df['Share gdp'])
        share_pop = list(sub_df['Share population'])

        cum_share_pop = [0]
        cum_share_gdp = [0]

        for k in range(len(share_pop)):
            cum_share_pop.append(share_pop[k] + cum_share_pop[-1])
            cum_share_gdp.append(share_gdp[k] + cum_share_gdp[-1])

        lorenz[y] = {
            "Cumulative share pop": cum_share_pop,
            "Cumulative share gdp": cum_share_gdp
        }
    return lorenz



def compute_gini(file_path, return_Lorenz = False,python = False, sce = "RICE"):
    data = read_results(file_path)
    data = data[sce]
    if "World" in data.keys():
        data.pop("World")

    if python:
        for r in data.keys():
            data[r]["Output, net net trill 2019$"] = data[r].pop("ynet")
            data[r]["Population (exogenous)"] = data[r].pop("pop")

    data = get_full_results(data)
    df = full_results_to_df(data)
    lorenz = compute_lorenz_curve(df)

    gini = []

    for y in range(len(lorenz.keys())):
        gini_value = 0
        for k in range(len(lorenz[y]["Cumulative share pop"]) - 1):
            gini_value += (lorenz[y]["Cumulative share pop"][k + 1] - lorenz[y]["Cumulative share pop"][k]) * \
                          (lorenz[y]["Cumulative share gdp"][k + 1] + lorenz[y]["Cumulative share gdp"][k])
        gini_value = 1 - gini_value
        gini.append(gini_value)

    if return_Lorenz :
        return gini, lorenz
    return gini

def convexity_check(lorenz):
    convex = True
    for y in lorenz.keys():
        for k in range(len(lorenz[y]["Cumulative share pop"])-2):
            slope = (lorenz[y]["Cumulative share gdp"][k+2] - lorenz[y]["Cumulative share gdp"][k])/\
                    (lorenz[y]["Cumulative share pop"][k + 2] - lorenz[y]["Cumulative share pop"][k])

            value = slope * (lorenz[y]["Cumulative share pop"][k + 1] - lorenz[y]["Cumulative share pop"][k]) \
                    + lorenz[y]["Cumulative share gdp"][k]

            if value < lorenz[y]["Cumulative share gdp"][k+1] :
                convex = False
    return convex


if __name__ == '__main__':

    path = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))

    path_nash = os.path.join(path, "climate_damage/outputs/rice2023_nash.csv")
    path_negishi = os.path.join(path, "climate_damage/outputs/rice2023_negishi.csv")


    gini_nash,lorenz_nash = compute_gini(path_nash, return_Lorenz=True, sce= "Medium")
    gini_negishi,lorenz_negishi = compute_gini(path_negishi, return_Lorenz=True, sce= "Medium")


    gini_nash_optimistic,lorenz_nash_optimistic = compute_gini(path_nash, return_Lorenz=True, sce= "Optimistic")
    gini_negishi_optimistic,lorenz_negishi_optimistic = compute_gini(path_negishi, return_Lorenz=True, sce= "Optimistic")


    gini_nash_pessimistic,lorenz_nash_pessimistic = compute_gini(path_nash, return_Lorenz=True, sce= "Pessimistic")
    gini_negishi_pessimistic,lorenz_negishi_pessimistic = compute_gini(path_negishi, return_Lorenz=True, sce= "Pessimistic")

    year = [2020 + i * 5 for i in range(len(gini_negishi))]
    fig = plt.figure()
    ax = fig.add_subplot(111)

    plt.plot(year, gini_negishi, color='blue', linewidth=2, label="Negishi-Medium")
    plt.plot(year, gini_negishi_optimistic,'--', color='blue', linewidth=2, label="Negishi-Optimistic")
    plt.plot(year, gini_negishi_pessimistic,'-.', color='blue', linewidth=2, label="Negishi-Pessimistic")


    plt.plot(year, gini_nash, color='red', linewidth=2, label="Nash-Medium")
    plt.plot(year, gini_nash_optimistic,'--', color='red', linewidth=2, label="Nash-Optimistic")
    plt.plot(year, gini_nash_pessimistic,'-.', color='red', linewidth=2, label="Nash-Pessimistic")

    plt.xlabel('Year', fontsize="20")
    plt.ylabel('GINI index', fontsize="20")
    for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
        tickLabel.set_fontsize(15)
    plt.grid(axis='y')
    plt.grid(color='black', linestyle='-', linewidth=1)
    plt.legend(fontsize="20")
    plt.show()

    # print(convexity_check(lorenz_negishi))
    # print(convexity_check(lorenz_nash))


    for k in [0,6,16]:

        fig = plt.figure()
        ax = fig.add_subplot(111)
        plt.plot(lorenz_negishi[k]["Cumulative share pop"],lorenz_negishi[k]["Cumulative share pop"], color = 'black', linewidth = 2, label="Reference")

        plt.plot(lorenz_negishi[k]["Cumulative share pop"],lorenz_negishi[k]["Cumulative share gdp"],  color = 'blue', linewidth = 2, label="GINI Negishi = " + str(round(gini_negishi[k],3)))
        plt.plot(lorenz_negishi_optimistic[k]["Cumulative share pop"],lorenz_negishi_optimistic[k]["Cumulative share gdp"],'--', color = 'blue', linewidth = 2, label="GINI Negishi-Optimistic = " + str(round(gini_negishi_optimistic[k],3)))
        plt.plot(lorenz_negishi_pessimistic[k]["Cumulative share pop"],lorenz_negishi_pessimistic[k]["Cumulative share gdp"],'-.', color = 'blue', linewidth = 2, label="GINI Negishi-Pessimistic = " + str(round(gini_negishi_pessimistic[k],3)))


        plt.plot(lorenz_nash[k]["Cumulative share pop"],lorenz_nash[k]["Cumulative share gdp"], color = 'red', linewidth = 2, label="GINI Nash = " + str(round(gini_nash[k],3)))
        plt.plot(lorenz_nash_optimistic[k]["Cumulative share pop"],
                 lorenz_nash_optimistic[k]["Cumulative share gdp"], '--', color='red', linewidth=2,
                 label="GINI Nash-Optimistic = " + str(round(gini_nash_optimistic[k], 3)))
        plt.plot(lorenz_nash_pessimistic[k]["Cumulative share pop"],
                 lorenz_nash_pessimistic[k]["Cumulative share gdp"], '-.', color='red', linewidth=2,
                 label="GINI Nash-Pessimistic = " + str(round(gini_nash_pessimistic[k], 3)))

        plt.xlabel('Cumulative share pop', fontsize="20")
        plt.ylabel('Cumulative share gdp', fontsize="20")
        for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
            tickLabel.set_fontsize(15)
        plt.grid(axis='y')
        plt.grid(color='black', linestyle='-', linewidth=1)
        plt.legend(fontsize="20")
        plt.title("Lorenz curve in "+ str(2020+ 5 * k),fontsize="20")
        plt.show()

