# When calling odeint we suggested using
#
# obs = odeint(enzSys, y0, times, args=(param,) )
#
# Why do we use args=(param,) here?
#
# 1) what does args=XXX mean

# suppose we define a function which performs a calculation
# its arguments: a,b,c
def do_calc( a, b, c):
    return (a+b)/c

# we can call this by using
do_calc(6,4,2)
# returns 5

# alternatively we can use keywords to define the arguments passed
do_calc(a=6,b=4,c=2)
# returns 5

# if we use keywords we can pass the arguments in any order
do_calc(c=2,a=6,b=4)
# returns 5

# i.e. using b=4 when calling the function, forces the function to associate the
# argument 4 with variable b whatever order the arguments are in.

# (compare to calling the same arguments without keywords)
do_calc(2,6,4)
# returns 2

# odeint has many optional keyword arguments that can be used to
# control the algorithm used, stepsize choice, etc

#scipy.integrate.odeint(func, y0, t, args=(), Dfun=None, col_deriv=0,
#    full_output=0, ml=None, mu=None, rtol=None, atol=None, tcrit=None,
#    h0=0.0, hmax=0.0, hmin=0.0, ixpr=0, mxstep=0, mxhnil=0, mxordn=12,
#    mxords=5, printmessg=0)
# for explanation see
# http://docs.scipy.org/doc/scipy-0.16.0/reference/generated/scipy.integrate.odeint.html

# in
# obs = odeint(enzSys, y0, times, args=(param,) )
#
# the "args=" is the keyword so that the paramaters are passed to odeint
# associated with the args variable

# what does the =(param,) mean?

# lets build our own toy odeint which just prints its arguments
# and calls the function

# we might expect it does this:

def my_odeint(func,y,t,args=()):
    print "my_odeint called with function func=",func,type(func)
    print "my_odeint called with variable y=",y,type(y)
    print "my_odeint called with variable t=",t,type(t)
    print "my_odeint called with variable args=",args,type(args)
    print "\n"
    func(y,t,args)
    return

# to use this we need a toy ydot which is the
# function that calculates the derivative of y at
# time t, using model parameters p
# for this test it just prints out its
# arguments...

def ydot(y,t,p):
    print "ydot called with y=",y,type(y)
    print "ydot called with t=",t,type(t)
    print "ydot called with p=",p,type(p)

# now we can try it out
my_odeint(ydot,1,2,(1,2,3))

# my_odeint called with function func= <function ydot at 0x1194eb668> <type 'function'>
# my_odeint called with variable y= 1 <type 'int'>
# my_odeint called with variable t= 2 <type 'int'>
# my_odeint called with variable args= (1, 2, 3) <type 'tuple'>
#
# ydot called with y= 1 <type 'int'>
# ydot called with t= 2 <type 'int'>
# ydot called with p= (1, 2, 3) <type 'tuple'>

# Here the odeint calls the function passed to it
# with arguments y,t and p
# the ydot function recieves its 3 parameters in a tuple p


# However in reality the odeint calls the function using the modified command
#
#  func(y,t,*args)
#
# The star here unpacks the arguments, so that if args=(arg1,arg2,arg3)
# the above command is equivalent to:
#
#  func(y,t,a1,a2,a3)
#
# Therefore the real odeint in SciPy is designed to have a "ydot" function
# which looks like this:
#
#  def ydot(y,t,p1,p2,p3...)
#
# where each parameter is a separate argument, rather than combined in a tuple
#
# It is a personal choice how you prefer to define your ydot. Suppose we want to
# keep the same model where parameters are passed as a single tuple (helps
# if we want to adjust number of parameters used). To do get it to the
# ydot function as a tuple we need to "double wrap" it when giving it to odeint,
# so that after odeint unpacks it, the parameters are still stored together:

# to double wrap a tuple we need to use
# a command like this
a=((1,2,3),)
print a,type(a)
# output is ((1, 2, 3),) <type 'tuple'>
# note it is "double wrapped"

# if we did ommit the comma
# Python thinks the brackets are defining an expression
# e.g. a = (1.+2.)/3.
# rather than defining a tuple
# the extra comma forces Python to recognise we want to create a tuple
b=((1,2,3))
print b,type(b)
# output is (1, 2, 3) <type 'tuple'>
# note it is not double wrapped

# so now we can look again at odeint
# lets modify it to unpack the args
def my_odeint2(func,y,t,args=()):
    print "my_odeint called with function func=",func,type(func)
    print "my_odeint called with variable y=",y,type(y)
    print "my_odeint called with variable t=",t,type(t)
    print "my_odeint called with variable args=",args,type(args)
    print "\n"
    # call function func after unpacking args
    func(y,t,*args)
    return

# now we can call it with parameters double wrapped
my_odeint2(ydot,1,2,((1,2,3),))
#
# output is now
#
#my_odeint called with function func= <function ydot at 0x1194ebc08> <type 'function'>
#my_odeint called with variable y= 1 <type 'int'>
#my_odeint called with variable t= 2 <type 'int'>
#my_odeint called with variable args= ((1, 2, 3),) <type 'tuple'>
#
#ydot called with y= 1 <type 'int'>
#ydot called with t= 2 <type 'int'>
#ydot called with p= (1, 2, 3) <type 'tuple'>


# to put this together
k1=1
k2=10
k3=0.1
params=(k1,k2,k3)
my_odeint2(ydot,1.0,0.0,args=(params,))
