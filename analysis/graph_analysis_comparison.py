import matplotlib.pyplot as plt
import numpy as np
from tools.tools import *
from tools.analysis_tools import *
import seaborn as sns

path = os.path.dirname(os.path.dirname(__file__))
data_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_negishi.csv"))
data10_negishi = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_negishi_10asia.csv"))

data_nash = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nash.csv"))
data10_nash = read_uncerainties_results(os.path.join(path,"spatial_consistency/outputs/rice2023_nash_10asia.csv"))

data_dict = {
    'Nash + Low Damage': {
        '1Asia': data_nash['Nordhaus'],
        '10Asia': data10_nash['Nordhaus']},
    'Nash + Middle Damage': {
        '1Asia': data_nash['Middle-Damage'],
        '10Asia': data10_nash['Middle-Damage']},
    'Nash + Strong Damage': {
        '1Asia': data_nash['Standard'],
        '10Asia': data10_nash['Standard']},
    'Negishi + Low Damage': {
        '1Asia': data_negishi['Nordhaus'],
        '10Asia': data10_negishi['Nordhaus']},
    'Negishi + Middle Damage': {
        '1Asia': data_negishi['Middle-Damage'],
        '10Asia': data10_negishi['Middle-Damage']},
    'Negishi + Strong Damage': {
        '1Asia': data_negishi['Standard'],
        '10Asia': data10_negishi['Standard']},
}

for m in data_dict.keys():
    for asia in data_dict[m].keys():
        for r in data_dict[m][asia].keys():
            for p in data_dict[m][asia][r].keys():
                data_dict[m][asia][r][p] = data_dict[m][asia][r][p][:90]


data = {
    'region' :[],
    'value' : [],
    'model' : []
}

for m in data_dict.keys() :
    for r in data_dict[m]['1Asia'].keys():
        if r != "World" and r != "ASIA":
            emission_control = (np.array(data_dict[m]['10Asia'][r]["Emissions control rate"][:90])\
                               - np.array(data_dict[m]['1Asia'][r]["Emissions control rate"][:90]))
            for t in emission_control:
                data['region'].append(r)
                data['value'].append(t)
                data['model'].append(m)


df = pd.DataFrame(data)
# Create additional grouping data
# Plots graph
sns.boxplot(x='region', y='value', data=df, hue='model')
plt.title('Change in Emission control',fontsize= 35)
plt.legend(bbox_to_anchor=(1.05, 1),fontsize= 20,loc='upper left')
plt.xlabel('', fontsize="25")
plt.ylabel('', fontsize="25")
for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
    tickLabel.set_fontsize(25)
plt.show()

data = {
    'region' :[],
    'value' : [],
    'model' : []
}

for m in data_dict.keys() :
        emission_control = (np.array(data_dict[m]['10Asia']['ASIA0']["Emissions control rate"][:90])\
                           - np.array(data_dict[m]['10Asia']['ASIA2']["Emissions control rate"][:90]))
        for t in emission_control:
            data['region'].append('"Sub-Asia n°1" / "Sub-Asia  n°3"')
            data['value'].append(t)
            data['model'].append(m)

        emission_control = (np.array(data_dict[m]['10Asia']['ASIA0']["Emissions control rate"][:90])\
                           - np.array(data_dict[m]['1Asia']['ASIA']["Emissions control rate"][:90]))
        for t in emission_control:
            data['region'].append('"Sub-Asia n°X" / Asia')
            data['value'].append(t)
            data['model'].append(m)





df = pd.DataFrame(data)
# Create additional grouping data
# Plots graph
sns.boxplot(x='region', y='value', data=df, hue='model')
plt.title('Change in Emission control',fontsize= 35)
plt.legend(bbox_to_anchor=(1.05, 1),fontsize= 20,loc='upper left')
plt.xlabel('', fontsize="25")
plt.ylabel('', fontsize="25")
for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
    tickLabel.set_fontsize(25)
plt.show()



data = {
    'param' :[],
    'value' : [],
    'model' : []
}
for m in data_dict.keys() :
    delta_tatm = np.array(data_dict[m]['10Asia']['World']["Atmospheric temperature (deg c above preind)"]) \
                    - np.array(data_dict[m]['1Asia']['World']["Atmospheric temperature (deg c above preind)"])
    delta_eco2 = np.array(data_dict[m]['10Asia']['World']["Total CO2 Emissions, GTCO2/year"]) \
                    - np.array(data_dict[m]['1Asia']['World']["Total CO2 Emissions, GTCO2/year"])
    for t in range(len(delta_tatm)):
        data['param'].append('T')
        data['value'].append(delta_tatm[t])
        data['model'].append(m)

        data['param'].append('CO2')
        data['value'].append(delta_eco2[t])
        data['model'].append(m)


df = pd.DataFrame(data)
# Create additional grouping data
# Plots graph
sns.boxplot(x='param', y='value', data=df[df['param']=='T'], hue='model')
plt.title('Change in temperature (°C)',fontsize= 35)
plt.legend(fontsize= 35,loc='upper right')
for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
    tickLabel.set_fontsize(25)
plt.show()


sns.boxplot(x='param', y='value', data=df[df['param']=='CO2'], hue='model')
plt.title('Change in co2 emissions')
plt.show()




data = {
    'param' :[],
    'value' : [],
    'model' : []
}

for m in data_dict.keys() :
    yy = 0
    yy10 = 0
    for r in data_dict[m]['1Asia'].keys():
        if r != "World" :
            yy += np.array(data_dict[m]['1Asia'][r]["Output, net net trill 2019$"])
    for r in data_dict[m]['10Asia'].keys():
        if r != "World" :
            yy10 += np.array(data_dict[m]['10Asia'][r]["Output, net net trill 2019$"])
    delta_y = yy10 - yy
    for t in delta_y:
        data['param'].append('Change in GDP')
        data['value'].append(t)
        data['model'].append(m)

df = pd.DataFrame(data)
# Create additional grouping data
# Plots graph
sns.boxplot(x='param', y='value', data=df[df['param']=='Change in GDP'], hue='model')
plt.title('Change in GDP')
plt.show()

data = {
    'param' :[],
    'value' : [],
    'model' : []
}
for m in data_dict.keys() :
    yy = 0
    yy10 = 0
    pop = 0
    for r in data_dict[m]['1Asia'].keys():
        if r != "World" :
            yy += np.array(data_dict[m]['1Asia'][r]["Output, net net trill 2019$"])
            pop += np.array(data_dict[m]['1Asia'][r]["Population (exogenous)"])
    for r in data_dict[m]['10Asia'].keys():
        if r != "World" :
            yy10 += np.array(data_dict[m]['10Asia'][r]["Output, net net trill 2019$"])
    delta_y = (yy10 - yy) / pop * 1000
    for t in delta_y:
        data['param'].append('Change in GDP per capita')
        data['value'].append(t)
        data['model'].append(m)

df = pd.DataFrame(data)
# Create additional grouping data
# Plots graph
sns.boxplot(x='param', y='value', data=df[df['param']=='Change in GDP per capita'], hue='model')
plt.title('Change in GDP per capita (000 $/hab)',fontsize= 35)
for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
    tickLabel.set_fontsize(25)
plt.legend(fontsize= 35,loc='lower right')
plt.show()
