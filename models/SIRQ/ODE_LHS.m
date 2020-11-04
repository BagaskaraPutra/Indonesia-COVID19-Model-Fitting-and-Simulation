function dydt=ODE_LHS(model,t,y,LHSmatrix,x)
dydt = zeros(numel(model.allStateName),1);
%% PARAMETERS %%
Npop = 0;
for i=1:numel(model.state)
    Npop = Npop + model.state.(model.allStateName{i}).initial; 
end

% Load parameter from LHSmatrix
beta = LHSmatrix (x,find(strcmp(model.paramName,'beta')));
r_I_Q = LHSmatrix (x,find(strcmp(model.paramName,'r_I_Q')));
gamma = LHSmatrix (x,find(strcmp(model.paramName,'gamma')));
muI = LHSmatrix (x,find(strcmp(model.paramName,'muI')));

% Load state value from y
S = y(find(strcmp(model.allStateName,'S'))); 
I = y(find(strcmp(model.allStateName,'I')));
Q = y(find(strcmp(model.allStateName,'Q'))); 
R = y(find(strcmp(model.allStateName,'R'))); 
D = y(find(strcmp(model.allStateName,'D')));

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