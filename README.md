# Indonesia-COVID19-Model-Fitting-and-Simulation
Indonesia COVID-19 Modelling by Department of Electrical and Information Engineering Universitas Gadjah Mada\
This is an Octave/Matlab script for fitting and simulation of COVID-19 cases in various regions in Indonesia using various compartmental ODE models.\
This script uses the **lsqcurvefit** fitting algorithm inspired by [**ECheynet**](https://github.com/ECheynet/SEIR).\
It is compatible for both Octave 6.0.90 and Matlab.
## Octave 6.0.90 dependencies
Install Octave 6.0.90 from the [GNU Octave website](https://ftp.gnu.org/gnu/octave/)\
Install these packages through the Command Window:
```
pkg install -forge io
pkg install -forge statistics
pkg install -forge struct
```
## To Do:
**[SOLVED]** **PROBLEM:** Octave underfits models containing more than 2 compartments with no real world fitting data (SEIQRDP, SIRQN).\
**SOLUTION:** Load previously fitted parameters from Matlab for the initial guess when fitting using Octave. 

## Software Architecture
![Image of Software Architecture](https://github.com/BagaskaraPutra/Indonesia-COVID19-Model-Fitting-and-Simulation/blob/master/ArsitekturProgram.png)
