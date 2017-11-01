import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint
 
S0=10.0
C0=15.0
 
Ks=1000
Kc=400
 
a_c=1./500
a_s=1./900
 
rs=0.6
rc=0.5
 
s0=(S0,C0)
p=(rs,rc,Ks,Kc,a_c,a_s)
 
def sdot(s,t,p):
    rs,rc,Ks,Kc,a_c,a_s=p #sets the parameters to be used in the differential equation
    S,C=s
    dS = rs*S*(1. - S/Ks - a_c*C)
    dC = rc*C*(1. - C/Kc - a_s*S)
    return (dS,dC)
 
 
plt.close("all")
 
fig1 = plt.figure()
ax1=plt.subplot(1,1,1)
 
t_max=200
t_obs=np.linspace(0,t_max,1001) 
s_obs=odeint(sdot,s0,t_obs,args=(p,))
ax1.plot(t_obs, s_obs[:,0], 'b-',label='sheep') #this plots the first differential equation coded
ax1.plot(t_obs, s_obs[:,1], 'g-',label='cows') # plots the second differential equation
ax1.set_xlabel('time/year')
ax1.set_ylabel('population density / square km')
 
ax1.legend(loc='upper left')
fig1.show()
 
fig2 = plt.figure(figsize=(8,8))
ax2=plt.subplot(1,1,1)
 
ax2.plot(s_obs[:,[0]], s_obs[:,[1]], 'k-',label='trajectory')
ax2.plot(s_obs[0,[0]], s_obs[0,[1]], 'ro',label='initial state')
ax2.plot(s_obs[-1,[0]], s_obs[-1,[1]], 'rs',label='final state')
ax2.set_xlabel('sheep')
ax2.set_ylabel('cows')
 
# define each axis limits
# need to go slightly below 0 to show end states and  nullclines
C_min=-10
C_max=600
S_min=-10
S_max=1200
 
ax2.set_xlim((S_min,S_max))
ax2.set_ylim((C_min,C_max))
 
#Draw Nullclines
 
#nullcline1:
# dS=0    when   S=0
# this is the line along the C axis (y-axis)
#passes through points (0,C_min) and (0,C_max)
ax2.plot([0,0], [C_min,C_max], 'g--',label='S nullcline: S=0')
 
#nullcline2:
# dS=0    when   S=Ks-Ks*a_c*C
#passes through points (S(C_min),C_min) and (S(C_max),C_max)
# where S(C) = Ks-Ks*a_c*C
ax2.plot([Ks-Ks*a_c*C_min, Ks-Ks*a_c*C_max], [C_min,C_max], color='g', ls='dotted',label='S nullcline: S=Ks-Ks*a_c*C')
 
#nullcline3:
# dC=0    when   C=0
# this is the line along the S axis (x-axis)
ax2.plot([S_min,S_max], [0,0], 'b--',label='C nullcine: C=0')
 
#nullcline4:
# dC=0    when   C=Kc-Kc*a_s*S
#passes through points [S_min,C(S_min)] and [S_max,C(S_max)]
# where C(S) = Kc-Kc*a_s*S
ax2.plot([S_min,S_max],[Kc-Kc*a_s*S_min, Kc-Kc*a_s*S_max], color='b', ls='dotted',label='C nullcline: C=Kc-Kc*a_s*S')
 
 
 
#Draw equillibrium points
 
# equlibrium points when C and S nullclines intersect:
ax2.plot([0],[0], 'yo',label='equilibrium point')
ax2.plot([0],[Kc], 'yo')
ax2.plot([Ks],[0], 'yo')
 
 
 
ax2.legend()
fig2.show()