from numpy import *
from scipy.integrate import odeint
from scipy.stats import linregress
import matplotlib.pyplot as plt
 
def enzSys(y, t, p):  
    k1 = p[0]
    km1 = p[1]
    k2 = p[2]
 
    S = y[0]
    E = y[1]
    ES = y[2]
    P = y[3]
     
    dS  = -k1*E*S + km1*ES; 
    dE  = -k1*E*S + km1*ES + k2*ES;
    dES =  k1*E*S - km1*ES - k2*ES;
    dP  =  k2*ES;
    
 
    return [ dS, dE, dES, dP ]
 
def coopSys(y, t, p):  # p is the parameters, y is the input values
    k1 = p[0]
    km1 = p[1]
    k2 = p[2]
    n = p[3]
     
    S = y[0]
    E = y[1]
    ES = y[2]
    P = y[3]
     
    dS  = -n*k1*E*pow(S,n) + n*km1*ES; 
    dE  = -k1*E*pow(S,n) + km1*ES + k2*ES;
    dES =  k1*E*pow(S,n) - km1*ES - k2*ES;
    dP  =  k2*E*pow(S,n);
    
    return [ dS, dE, dES, dP ]
 
    # Just make a plot of P and superi
     
    #plt.close() 
    #plt.plot( yobs[:,0], yobs[:,2] )
    #plt.xlabel('[S]')
    #plt.ylabel('[ES]')
    #plt.savefig('enzSys-SvES-p1.png')
 
def hillEqn(S,Km,Vmax,n):
    Sn = pow(S,n)
     
    return Vmax*Sn/(Km + Sn)
     
def main():
 
    #############################################
    # Task A 1)
    print enzSys( [1,1,1,1], 0, [1.0, 0.5, 0.6])
     
    # Task A 2)
    times = arange(0,10,0.01)
    param = [1.0, 0.5, 0.6]
 
    y0 = [10, 10, 0, 0 ]
    yobs = odeint(enzSys, y0, times, args=(param,) )
 
    # Task A 3)
    plt.close()  # close any existing   
    plt.plot( times, yobs[:,0], label='S' )
    plt.plot( times, yobs[:,1], label='E' )
    plt.plot( times, yobs[:,2], label='ES' )
    plt.plot( times, yobs[:,3], label='P' )
    plt.legend( loc=0 )
    plt.xlabel('time')
    plt.ylabel('concentration')
    plt.show() 
    # Task A 4)
    plt.close()  # close any existing   
    plt.plot( times, yobs[:,0], label='S' )
    plt.plot( times, yobs[:,1], label='E' )
    plt.plot( times, yobs[:,2], label='ES' )
    plt.plot( times, yobs[:,3], label='P' )
    plt.plot( times, yobs[:,1] + yobs[:,2], label='E+ES' )
    plt.legend( loc=0 )
    plt.xlabel('time')
    plt.ylabel('concentration')
    plt.savefig('enzSys-tevol-v1-cons.png')
 
    # Task A 5)
    # perform the ode integration again with S >> E
    y0 = [10, 0.5, 0, 0 ]
    yobs = odeint(enzSys, y0, times, args=(param,) )
    plt.close()  # close any existing   
    plt.plot( times, yobs[:,0], label='S' )
    plt.plot( times, yobs[:,1], label='E' )
    plt.plot( times, yobs[:,2], label='ES' )
    plt.plot( times, yobs[:,3], label='P' )
    plt.legend( loc=1 )
    plt.xlabel('time')
    plt.ylabel('concentration')
    plt.show()
 
    # Task A 6)
    Etot = y0[1] + y0[2]
    MMapprox = param[2]*Etot*times
 
    slope, intercept, r_value, p_value, std_err = linregress(times,yobs[:,3])
    print "Estimate of k2 =", slope/Etot
 
    #############################################
    # Task B 3)
    y0 = [10, 0.5, 0, 0 ]
    param = [1.0, 0.5, 0.6]
    Km = (param[1] + param[2])/param[0]
    Etot = y0[1] + y0[2]
 
    S = arange(0,5,0.1)
     
    Pdot = []
    nv = range(1,7)
    for i in range(len(nv)):
        Vmax = nv[i]*Etot*param[2]
        Pdot.append( hillEqn( S,  Km, Vmax, nv[i] ))
        
    plt.close()  # close any existing
    for i in range(len(nv)):
        lab = 'n = ' + repr(nv[i])
        Vmax = nv[i]*Etot*param[2]
        plt.plot( S, Pdot[i]/Vmax, label=lab )
    plt.legend( loc=0 )
    plt.xlabel('[S]')
    plt.ylabel('d[P]/d[t]')
    plt.savefig('hill-equations.png')
 
         
main()