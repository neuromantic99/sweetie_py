from __future__ import division
import numpy as np
from scipy.integrate import odeint
import matplotlib.pyplot as plt
import seaborn as sns
import math

sns.set_style('white')
sns.set_palette('muted', 3)

def ydot(y, t, p):  
    tr = p[0]
    r0 = p[1]
    k = p[2]
    # define parameters
    
    s = y[0]
    i = y[1]
    r = y[2]
    
    #define initial conditions
    
    dsdt  = (-((i/tr) * r0 * s)) + k
    didt  = (i/tr) * (r0 * s - 1)
    drdt =  i / tr - k
    #set up differential equations
    
    return [dsdt, didt, drdt]
    #return outputs as a list
    
def main():
    times = range(10950)
    # time in days the model runs for
    
    r0 = 15
    tr = 8
    k = 4.435 * math.pow(10, -5)
    
    param = [tr, r0, k]
    # the parameters: infectivity period (days), reproduction number, births/capita/day 
    
    i = 4.055 * math.pow(10, -5)
    s = 1 / r0
    r = 1 - i - s 
    # set the proportion infected, resistant, susceptible
    
    y0 = [s,i,r] 
    
    yobs = odeint(ydot, y0, times, args=(param,) )
    
    date = [times[i] / 365 for i in range(len(times))]
    date = [date[i] + 1950 for i in range(len(date))]
    
    plt.close('all') # close all preexisting windows  
    fig_phase = plt.figure(figsize=(12,8))
    ax=fig_phase.add_subplot(1,1,1)
    ax.plot(yobs[:,0] * 100,yobs[:,1] * 100, label = 'Phase Space')
    ax.set_xlabel('Percentage Susceptible', fontsize = 13, labelpad = 10)
    ax.set_ylabel('Percentage Infected', fontsize = 13, labelpad = 10)
    ax.legend(loc = 'best', fontsize = 14)
    plt.annotate('Equilibrium', (yobs[:,0][-1] * 100,yobs[:,1][-1] * 100), fontsize = 13, color = 'red', weight = 'bold')
    fig_phase.show() 
    
        

    
main()

    
    
    
