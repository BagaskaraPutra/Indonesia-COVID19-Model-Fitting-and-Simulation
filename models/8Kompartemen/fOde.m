% Function calculating the differential equations for the COVID-19 model 
function dydt = fOde(t,y,param) 

q1  =param(1); 
q2  =param(2);
betat =param(3);
betav =param(4);
beta1 =param(5);
beta2 =param(6);
beta3 =param(7);
beta4 =param(8);
eta1 =param(9);
eta2 =param(10);
eta3 =param(11); 
delta1 =param(12);
delta2 =param(13);
theta =param(14); 
f1 =param(15);
f2 =param(16);
f3 =param(17);
d =param(18);
betav1 =param(19);
theta1 =param(20);
sigma =param(21);

dydt = zeros(8,1);
Sq = y(1); 
S = y(2); 
E1 = y(3); 
E2 = y(4); 
H = y(5); 
R= y(6);
D=y(7);
V = y(8);
T=10000;

dSqdt=-q2*Sq+q1*S;

dSdt=-(q1+betav*V+beta2*E2+beta1*E1+betav1*V)*S+q2*Sq-(beta4*E1+beta3*E2)*S; %+betat*T

dE1dt=(beta1)*S*E1 -eta1*E1 -(theta1+sigma)*E1 + beta3*S*E2 +betav1*S*V +betat*T;

dE2dt=(beta2)*S*E2 -(eta2+delta1+theta)*E2 + beta4*S*E1 + betav*S*V +sigma*E1 +0.1*betat*T;

dHdt=theta*E2-(eta3+delta2)*H+theta1*E1;

dRdt=eta1*E1+eta2*E2+eta3*H;

dDdt=delta1*E2+delta2*H;

dVdt=f1*E1+f2*E2+f3*H-d*V;

dydt(1) = dSqdt;  
dydt(2) = dSdt; 
dydt(3) = dE1dt; 
dydt(4) = dE2dt; 
dydt(5) = dHdt; 
dydt(6) = dRdt; 
dydt(7) = dDdt;
dydt(8) = dVdt;

end