% Function calculating the differential equations for the COVID-19 model 
function dydt = fOde(t,y,param) 
global Npop

beta = param(1);
gamma = param(2);
muI = param(3);

dydt = zeros(4,1);
S = y(1); 
I = y(2); 
r = y(3); 
D = y(4);

dSdt = - beta*S*I/Npop;

dIdt = beta*S*I/Npop - (gamma+muI)*I;

drdt = gamma*I;

dDdt = muI*I;

dydt(1) = dSdt;  
dydt(2) = dIdt; 
dydt(3) = drdt; 
dydt(4) = dDdt;

end