% Function calculating the differential equations for the COVID-19 model 
function dydt = fOde(t,y, param) 
global Npop;
dydt = zeros(7,1);
S = y(1); 
E = y(2); 
I = y(3); 
Q = y(4); 
R = y(5); 
D = y(6);
P = y(7);

alpha = param(1);
beta = param(2);
gamma = param(3);
delta = param(4);
lambda0 = param(5);
kappa0 = param(6);

dSdt = -beta*S*I/Npop - alpha*S;
dEdt = beta*S*I/Npop - gamma*E;
dIdt = gamma*E - delta*I;
dQdt = delta*I - lambda0*Q - kappa0*Q;
dRdt = lambda0*Q;
dDdt = kappa0*Q;
dPdt = alpha*S;

dydt(1) = dSdt;  
dydt(2) = dEdt; 
dydt(3) = dIdt; 
dydt(4) = dQdt; 
dydt(5) = dRdt; 
dydt(6) = dDdt;
dydt(7) = dPdt;