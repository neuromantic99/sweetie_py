import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint

# Variable / Parameter names
#
# n_cells #-- size of grid
# x_coords = np.arange(0,n_cells) #-- x_coordinates of each cell
#
# grid #-- array of values representing concentration in each cell
# kD #-- diffusion rate
#

def d_diffusion(grid,kD):

    n_cells=len(grid)
    d_diff = np.zeros(n_cells)

    # d_diff[i] is the rate of change of
    # conc. in cell grid[i]

    # the rate of flow out of each cell
    # into each neighbour
    # is equal to kD*[conc in cell]

    # we need to use a loop over each cell
    # in the 1D grid and calculate the net rate of
    # change due to diffusion

    # hint
    # 1. write a loop over each cell
    # 2. identify the neighbouring cells
    # 3. sum the rates of flows in and out of this cell
    # 4. store this value in the appropriate element of
    #     array d_diff
    for i in range(0,(n_cells-1)):
        
        cell_i = grid[i]
        prev_cell = grid[i-1]
        next_cell = grid[i+1]
        r_out = kD * (cell_i) * 2
        r_in = kD * (prev_cell + next_cell)
        d_diff[i] = r_in + r_out
        
    
    
    
    return d_diff


def sdot(s,t,params):

    (kD,)=params
    # kD is the rate of diffusion

    # s is an array of values
    # for each cell in the grid

    # find size of grid
    n_cells=len(s)

    # create rate array for results
    ds=np.zeros(n_cells)

    # process any reactions occuring in each cell
    for i in range(n_cells):
        pass # the pass command allows us to have an empty loop
             # meaning 'do nothing' this can
             # act as a placeholder for when we want to
             # add reactions e.g. ds[i]= -k*s[i] for degradation

    # calc net rate diffusion in each cell
    # using external function that acts on grid s
    ds=ds+d_diffusion(s,kD)

    return ds



n_cells=20
x_coords=np.arange(0,n_cells)

# create an array for initial cell conditions
s0=np.zeros(n_cells)

# set all initial concentrations to 1.0
# except in cell 5 which has concentration 3.0


# set diffusion rate
# same for all cells
kD=0.2

# create array of time observations
t_min=0
t_max=80.
t_interval=10.
t_obs=np.arange(t_min,t_max,t_interval)

# set initial conditions and parameters
s=s0
params=(kD,)

# run simulation
s_obs=odeint(sdot,s,t_obs,args=(params,),mxstep=5000000)
# mxstep=5000000 allows more calculations to be taken per timestep
# otherwise Python may complain it is taking too long to solve

# convert to array so we can manipulate it more easily
s_obs=np.array(s_obs)

# plot results
plt.close("all")
fig1 = plt.figure()
ax=plt.subplot(1,1,1)

# each row of s_obs is a time observation
# containing a column for each cell
n_obs=len(t_obs)
for i in range(n_obs):
    ax.plot(x_coords, s_obs[i,:])

ax.set_ylim([0.8,3.3])
fig1.show()
