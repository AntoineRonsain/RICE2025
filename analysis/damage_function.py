import matplotlib.pyplot as plt
import numpy as np
import plotly.graph_objects as go



def find_alpha_pi3(t1, t2,p1 = 0.5 , p2 = 0.99, a2= 0.00284):
    '''
    Damage function defined as follow :
    D(t) = 1 - 1 / (1 + a2*t**2 +  a3*t**n3)
    with pi2 = 0.00284 and pi3 abd alpha to be defined
    to determine pi3 and alpha, 2 points are arbitrary fixed  :
    For example +4°C => -50% GDP
              +8°C => -99% GDP
    Therefore (t1, p1)=(4, 0.5) et (t2, p2)=(8, 0.99)
    '''
    b1 = 1. / (1.-p1) - 1. - a2 * t1**2
    b2 = 1. / (1.-p2) - 1. - a2 * t2**2
    n3 = np.log(b1/b2) / np.log(t1/t2)
    a3 = b1 / t1**n3
    return n3, a3


X = np.linspace(0,8,50).tolist()

a1 = 0
a2 = 0.00284
a2_n = 0.003467
a2_n2 = 0.003467
a3 = 1.570397e-05
a3_n = 0
n3 = 7.315027067


n3_2,a3_n2 = find_alpha_pi3(7,15)
print(n3_2,a3_n2)

Nordhaus = np.array([1 - 1/ (1 + a2_n* x ** 2 + a3_n * x **n3)  for x in X])
Midd = np.array([1 - 1/ (1 + a2_n2* x ** 2 + a3_n2 * x **n3_2)  for x in X])
Ronsain = np.array([1 - 1/ (1 + a2 * x ** 2 + a3 * x **n3)  for x in X])

fig = go.Figure()
fig.add_trace(go.Scatter(x= X, y=Nordhaus,
                    mode='lines',
                    name='Nordhaus damage'))
fig.add_trace(go.Scatter(x= X, y=Midd,
                    mode='lines',
                    name='Middle-Damage'))
fig.add_trace(go.Scatter(x= X, y=Ronsain,
                    mode='lines',
                    name='Ronsain damage'))
fig.update_xaxes(title_text="Temperature (in °C)")
fig.update_yaxes(title_text="Fraction of damage on production output")
#fig.show()

fig = plt.figure()
ax = fig.add_subplot(111)
plt.plot(X, 100* Nordhaus,linewidth=2, label='Low (Nordhaus) damage')
plt.plot(X, 100* Midd, linewidth=2,label='Middle damage')
plt.plot(X, 100* Ronsain,linewidth=2, label='Strong damage')
for tickLabel in plt.gca().get_xticklabels() + plt.gca().get_yticklabels():
    tickLabel.set_fontsize(20)
plt.xlabel('Atmospheric temperature (in °C)', fontsize="20")
plt.ylabel('Damages (in % of GDP)', fontsize="20")
plt.grid(axis='y')
plt.legend(fontsize = "20")
plt.grid(color='black', linestyle='-', linewidth=1)
ax.legend(fontsize = "20",loc='upper left')
plt.show()