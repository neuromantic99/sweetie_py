# plots phase diagram for the
# toggle switch system

import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint
import math

# for task4d) copy your rate equation (e.g. sdot) below this line:

def toggle(y, t, p):  
    a1 = p[0]
    a2 = p[1]
    n2 = p[2]
    n1 = p[3]
    k1 = p[4]
    k2 = p[5]
    kd1 = p[6]
    kd2 = p[7]
    # define parameters
    
    p1 = y[0]
    p2 = y[1]
    # define the initial conditions
    
    dp1dt = (a1 / (1 + math.pow((p2 / k2), n2))) - kd1 * p1
    dp2dt = (a2 / (1 + math.pow((p1 / k1), n1))) - kd2 * p2
    # set up the differential equation to be run
    
    return [ dp1dt, dp2dt ]

# define parameter values
a1=140.0
a2=15.0
n2=2.5
n1=1.0
kd1=1.0
kd2=1.0
K1=1.0
K2=1.0

# the data points below define the selectrix
# determined for the above parameter values

x_points=[0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8,
        0.9, 1.0, 1.1, 1.2, 1.3, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0,
	4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 8.5,
	9.0, 9.5, 10.0, 10.5, 11.0, 11.5, 12.0, 12.5,
	13.0, 13.5, 14.0, 14.5, 15.0, 15.5, 16.0, 16.5,
	17.0, 17.5, 18.0, 18.5, 19.0, 19.5, 20.0]

y_points=[3.51, 3.71, 3.9, 4.1, 4.31, 4.51,
        4.72, 4.93, 5.14, 5.35, 5.57, 5.79, 6.01,
        6.2, 6.69, 7.86, 9.08, 10.33,
	11.61, 12.92, 14.24, 15.59, 16.94, 18.3,
	19.68, 21.06, 22.44, 23.84, 25.23, 26.63,
	28.04, 29.44, 30.85, 32.26, 33.68, 35.09,
	36.51, 37.93, 39.35, 40.77, 42.19, 43.61,
	45.04, 46.46, 47.89, 49.32, 50.74, 52.17,
	53.6, 55.03, 56.46, 57.88]

# close any open plots
plt.close('all')

# create figure and axes
fig1=plt.figure()
ax=fig1.add_subplot(1,1,1)

# calculate and draw nullcline for dP1/dt=0
P2 = np.linspace(0,20,10000)
nullP1  = (a1/(1.0+(P2/K2)**n2))/kd1
ax.plot(nullP1,P2,ls='--',label='dP1/dt = 0')

# calculate and draw nullcline for dP2/dt=0
P1 = np.linspace(0,200,10000)
nullP2  = (a2/(1.0+(P1/K1)**n1))/kd2
ax.plot(P1,nullP2,ls='--',label='dP2/dt = 0')

# add code below to add additional objects to the plot

separatrix = ax.plot(x_points, y_points, label = 'seperatrix')

times = np.arange(0,60,0.01)
    # sets the start time, the end time, and the number of intermediate times
    
param = [140.0, 15.0, 2.5, 1.0, 1.0, 1.0, 1.0, 1.0]
    # set the values of the parameters
 
y0 = [50, 12]
    # set the initial conditions
    
yobs = odeint(toggle, y0, times, args=(param,) )

dp1dt = ax.plot(times, yobs[:,0], label='dp1/dt' ) # plot the first rate
dp2dt = ax.plot( times, yobs[:,1], label='dp2/dt' )


# tidy up the plot
ax.legend(loc='upper right')

# use these bounds to see lin-log
# scale (easier to view all steady states)
ax.set_xscale("log")
ax.set_xlim(0.0,150)
ax.set_ylim(0,60)

# add labels
ax.set_xlabel('P1 concentration')
ax.set_ylabel('P2 concentration')
ax.set_title('Phase diagram P2 vs P1')

# display and save figure
fig1.show()
fig1.savefig('task4_phase_plot.png')
