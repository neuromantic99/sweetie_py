from __future__ import division
import numpy as np
from scipy.integrate import odeint
import matplotlib.pyplot as plt
import seaborn as sns

sns.set_style('dark')
sns.set_palette('bright')

def ydot(y, t, p):  
    tr = p[0]
    r0 = p[1]
    # define parameters
    
    s = y[0]
    i = y[1]
    r = y[2]
    #define initial conditions
    
    dsdt  = -((i/tr) * r0 * s) 
    didt  = (i/tr) * (r0 * s - 1)
    drdt =  i / tr
    #set up differential equations
    
    return [dsdt, didt, drdt]
    #return outputs as a list
    
def main():
    times = range(0,10000)
    # time in days the model runs for
    
    param = [8, 15]
    # the parameters: infectivity period (days), reproduction number 
    
    i = 1 / 10000
    r = 85/100 
    s = 1 - i - r
    # set the proportion infected, resistant, susceptible
    y0 = [s,i,r] 
    
    yobs = odeint(ydot, y0, times, args=(param,) )
    
    plt.close('all') # close all preexisting windows   
    
    plt.plot( times, yobs[:,0] * 100, label='Susceptible' ) 
    plt.plot( times, yobs[:,1] * 100, label='Infected' )
    plt.plot( times, yobs[:,2] * 100, label='Resistant' ) 
    plt.legend( loc='best' ) # set legend location
    plt.xlabel('Time (days) ') # set x-axis
    plt.ylabel('Percentage of Population ') # set y-axis
    plt.show() 

 
main()

    
    
    
