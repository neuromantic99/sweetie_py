from __future__ import division
import numpy as np
from scipy.integrate import odeint
import matplotlib.pyplot as plt
import seaborn as sns
import math

sns.set_style('dark')
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
    times = range((10950))
    # time in days the model runs for
    
    r0 = 15
    tr = 8
    k = 4.435 * math.pow(10, -5)
    
    param = [tr, r0, k]
    # the parameters: infectivity period (days), reproduction number, births/capita/day 
    
    i = 4.055 * math.pow(10, -4)
    s = 1/r0
    r = 1 - i - s 
    # set the proportion infected, resistant, susceptible
    
    print 1/ r0
    y0 = [s,i,r] 
    
    yobs = odeint(ydot, y0, times, args=(param,) )
    
    date = [times[i] / 365 for i in range(len(times))]
    date = [date[i] + 1950 for i in range(len(date))]
    plt.close('all') # close all preexisting windows   
    f, (ax1, ax2, ax3) = plt.subplots(3, sharex=True, sharey=False)
    ax2.plot( date, yobs[:,0] * 100, label='Susceptible' ) 
    ax1.plot( date, yobs[:,2] * 100, label='Resistant', c = 'olive') 
    ax3.plot( date, yobs[:,1] * 100, label='Infected' , c = 'firebrick')
    ax1.legend( loc='best', fontsize = '12') # set legend location
    ax2.legend( loc='best', fontsize = '12')
    ax3.legend( loc='best', fontsize = '12')
    plt.xlabel('Year', fontsize = 13, labelpad = 10) # set x-axis
    ax2.set_ylabel('Percentage of Population ', fontsize = 13, labelpad = 16) # set y-axis
    sns.despine()
    plt.show() 

    #print yobs[:,0][-1]
main()

    
    
    
