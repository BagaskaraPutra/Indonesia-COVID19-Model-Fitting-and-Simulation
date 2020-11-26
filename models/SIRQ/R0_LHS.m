function R0 = R0_LHS(model,t,LHSmatrix,x)
%% PARAMETERS %%
% Load parameter from LHSmatrix
beta = LHSmatrix (x,find(strcmp(model.paramName,'beta')));
r_I_Q = LHSmatrix (x,find(strcmp(model.paramName,'r_I_Q')));
gamma = LHSmatrix (x,find(strcmp(model.paramName,'gamma')));
muI = LHSmatrix (x,find(strcmp(model.paramName,'muI')));

R0 = beta/r_I_Q;