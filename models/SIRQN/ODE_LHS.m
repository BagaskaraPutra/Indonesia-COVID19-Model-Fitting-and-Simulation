function dydt=ODE_LHS(model,t,y,LHSmatrix,x)
dydt = zeros(numel(model.allStateName),1);
%% PARAMETERS %%
Npop = 0;
for i=1:numel(model.state)
    Npop = Npop + model.state.(model.allStateName{i}).initial; 
end

% Load parameter from LHSmatrix
beta = LHSmatrix (x,find(strcmp(model.paramName,'beta')));
r_S_NQ = LHSmatrix (x,find(strcmp(model.paramName,'r_S_NQ')));
r_NQ_S = LHSmatrix (x,find(strcmp(model.paramName,'r_NQ_S')));
r_NQ_Q = LHSmatrix (x,find(strcmp(model.paramName,'r_NQ_Q')));
r_NQ_ND = LHSmatrix (x,find(strcmp(model.paramName,'r_NQ_ND')));
r_I_Q = LHSmatrix (x,find(strcmp(model.paramName,'r_I_Q')));
gamma = LHSmatrix (x,find(strcmp(model.paramName,'gamma')));
muI = LHSmatrix (x,find(strcmp(model.paramName,'muI')));

% Load state value from y
S = y(find(strcmp(model.allStateName,'S')));
NQ = y(find(strcmp(model.allStateName,'NQ')));
ND = y(find(strcmp(model.allStateName,'ND')));
I = y(find(strcmp(model.allStateName,'I')));
Q = y(find(strcmp(model.allStateName,'Q'))); 
R = y(find(strcmp(model.allStateName,'R'))); 
D = y(find(strcmp(model.allStateName,'D')));

dSdt = -beta*S*I/Npop - r_S_NQ*S + r_NQ_S*NQ;
dNQdt = r_S_NQ*S - r_NQ_S*NQ - r_NQ_ND*NQ - r_NQ_Q*NQ;
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