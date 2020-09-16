% Function calculating the differential equations for the COVID-19 model 
function dydt = fOde(t,y, param) 
global Npop;
dydt = zeros(8,1);
S = y(1); 
NQ = y(2); 
NR = y(3); 
ND = y(4);
I = y(5);
Q = y(6); 
R = y(7); 
D = y(8);

beta = param(1); 
r_S_NQ = param(2); 
r_NR_S = param(3);
r_NQ_NR = param(4);
r_NQ_Q = param(5);
r_NQ_ND = param(6);
r_I_Q = param(7);
gamma = param(8);
muI = param(9);

dSdt = -beta*S*I/Npop - r_S_NQ*S + r_NR_S*NR;
dNQdt = r_S_NQ*S - r_NQ_NR*NQ - r_NQ_ND*NQ - r_NQ_Q*NQ;
dNRdt = -r_NR_S*NR + r_NQ_NR*NQ;
dNDdt = r_NQ_ND*NQ;
dIdt = beta*S*I/Npop - r_I_Q*I;
dQdt = r_NQ_Q*NQ + r_I_Q*I - gamma*Q - muI*Q;
dRdt = gamma*Q;
dDdt = muI*Q;

dydt(1) = dSdt;  
dydt(2) = dNQdt; 
dydt(3) = dNRdt; 
dydt(4) = dNDdt;
dydt(5) = dIdt;
dydt(6) = dQdt; 
dydt(7) = dRdt; 
dydt(8) = dDdt;