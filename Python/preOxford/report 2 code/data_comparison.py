from __future__ import division
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import math
from scipy.integrate import odeint

sns.set_style('dark')
sns.set_palette('bright')


def hist_data():
    with open('/Users/jimmy//Documents/measles_data.csv', 'r') as f:
        rows = [row for row in f]
        data = [rows[i].split(',') for i in range(len(rows))]
        date = [data[i][0] for i in range(len(data))]
        cases = [data[i][1] for i in range(len(data))]
        cases = [cases[i].rstrip() for i in range(len(cases))]
        cases = [int(cases[i]) for i in range(len(cases))]   
        
        percentinfect = [cases[i] / 50900000 * 100 for i in range(len(cases))]
        
    return date, percentinfect
        
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
    r = 1 - i -s 
    # set the proportion infected, resistant, susceptible
    
    y0 = [s,i,r] 
    
    yobs = odeint(ydot, y0, times, args=(param,) )
    
    date = [times[i] / 365 for i in range(len(times))]
    date = [date[i] + 1950 for i in range(len(date))]
    
    return date, yobs
    
histdate, histpercent = hist_data()
modeldate, yobs = main()   

plt.close('all') # close all preexisting windows   
f, (ax1, ax2) = plt.subplots(2, sharex=True, sharey=False)
ax2.plot( histdate, histpercent, label='Historical Data' ) 
ax1.plot( modeldate, yobs[:,1] * 100, label='Model', c = 'olive') 
ax1.legend( loc='best', fontsize = '12') # set legend location
ax1.set_xlim(1950, 1960)
ax2.legend( loc='best', fontsize = '12')
plt.xlabel('Year', fontsize = 13, labelpad = 10) # set x-axis
ax2.set_ylabel('Percentage of Population Infected ', fontsize = 13, labelpad = 16, position = [1,1.1]) # set y-axis
sns.despine()
plt.show() 

