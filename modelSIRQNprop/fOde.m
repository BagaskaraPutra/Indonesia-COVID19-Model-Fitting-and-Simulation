% Function calculating the differential equations for the COVID-19 model 
function dydt = fOde(t,y, param) 
global Npop;
dydt = zeros(7,1);
S = y(1); 
NQ = y(2); 
ND = y(3);
I = y(4);
Q = y(5); 
R = y(6); 
D = y(7);

beta = param(1); 
r_S_NQ = param(2); 
r_NQ_S = param(3);
r_NQ_Q = param(4);
r_NQ_ND = param(5);
r_I_Q = param(6);
gamma = param(7);
muI = param(8);

dSdt = -beta*S*I/Npop - r_S_NQ*S*NQ/Npop + r_NQ_S*NQ;
dNQdt = r_S_NQ*S*NQ/Npop - r_NQ_S*NQ - r_NQ_ND*NQ - r_NQ_Q*NQ;
dNDdt = r_NQ_ND*NQ;
dIdt = beta*S*I/Npop - r_I_Q*I;
dQdt = r_NQ_Q*NQ + r_I_Q*I - gamma*Q - muI*Q;
dRdt = gamma*Q;
dDdt = muI*Q;

dydt(1) = dSdt;  
dydt(2) = dNQdt; 
dydt(3) = dNDdt;
dydt(4) = dIdt;
dydt(5) = dQdt; 
dydt(6) = dRdt; 
dydt(7) = dDdt;