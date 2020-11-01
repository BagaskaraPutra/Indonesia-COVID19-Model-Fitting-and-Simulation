% Function calculating the differential equations for the COVID-19 model 
function dydt = fOde(t,y,param) 
global Npop
% Npop = 1;

beta = param(1);
gamma = param(2);
muI = param(3);
beta_s = param(4);
lambda = param(5);

% Rt = param(2);
% Trecov = param(3);
% Tdeath = param(4);
% Tinf = param(5);
% lambda = param(6);
% 
% beta_s = Rt/Tinf;
% gamma = 1/Trecov;
% muI = 1/Tdeath;
% % lambda = 1/Tinf;

dydt = zeros(numel(y),1);
S = y(1); 
Q = y(2); 
R = y(3); 
D = y(4);
Q_s = y(5);
R_s = y(6);
D_s = y(7);

dSdt = - beta*S*Q/Npop - beta_s*S*Q_s/Npop;
dQdt = beta*S*Q/Npop - (gamma+muI)*Q + lambda*Q_s;
dRdt = gamma*Q;
dDdt = muI*Q;
% Q_s = normrnd(1,0.1)*Q;
dQ_sdt = beta_s*S*Q_s/Npop - (gamma+muI+lambda)*Q_s;
dR_sdt = gamma*Q_s;
dD_sdt = muI*Q_s;

dydt(1) = dSdt;  
dydt(2) = dQdt; 
dydt(3) = dRdt; 
dydt(4) = dDdt;
dydt(5) = dQ_sdt; 
dydt(6) = dR_sdt; 
dydt(7) = dD_sdt;

end