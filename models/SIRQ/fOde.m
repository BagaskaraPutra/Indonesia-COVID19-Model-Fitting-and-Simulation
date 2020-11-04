% Function calculating the differential equations for the COVID-19 model 
function dydt = fOde(t,y, param) 
global Npop;
dydt = zeros(5,1);
S = y(1); 
I = y(2);
Q = y(3); 
R = y(4); 
D = y(5);

beta = param(1); 
r_I_Q = param(2);
gamma = param(3);
muI = param(4);

dSdt = -beta*S*I/Npop;
dIdt = beta*S*I/Npop - r_I_Q*I;
dQdt = r_I_Q*I - gamma*Q - muI*Q;
dRdt = gamma*Q;
dDdt = muI*Q;

dydt(1) = dSdt;  
dydt(2) = dIdt;
dydt(3) = dQdt; 
dydt(4) = dRdt; 
dydt(5) = dDdt;