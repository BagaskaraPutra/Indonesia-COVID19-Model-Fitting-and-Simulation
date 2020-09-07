% Function calculating the differential equations for the COVID-19 model 
% function dydt = fIstilahBaru(t,y, r_S_P, r_S_NI, r_NR_S, r_NI_NR, r_NI_P, r_P_R, r_NI_D, r_P_D) 
function dydt = fOde(t,y, param) 
global Npop;
dydt = zeros(6,1);
S = y(1); 
NI = y(2); 
NR = y(3); 
P = y(4); 
R = y(5); 
ND = y(6);
D = y(7);

r_S_P = param(1); 
r_S_NI = param(2); 
r_NR_S = param(3);
r_NI_NR = param(4);
r_NI_P = param(5);
r_P_R = param(6);
r_NI_ND = param(7);
r_P_D = param(8);

dSdt = -r_S_P*S*P/Npop - r_S_NI*S + r_NR_S*NR;
dNIdt = r_S_NI*S - r_NI_NR*NI - r_NI_P*NI - r_NI_ND*NI;
dNRdt = -r_NR_S*NR + r_NI_NR*NI;
dPdt = r_S_P*S*P/Npop + r_NI_P*NI - r_P_R*P - r_P_D*P;
dRdt = r_P_R*P;
dNDdt = r_NI_ND*NI;
dDdt = r_P_D*P;


dydt(1) = dSdt;  
dydt(2) = dNIdt; 
dydt(3) = dNRdt; 
dydt(4) = dPdt; 
dydt(5) = dRdt; 
dydt(6) = dNDdt; 
dydt(7) = dDdt;