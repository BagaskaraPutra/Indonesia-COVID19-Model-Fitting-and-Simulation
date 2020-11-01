% Function Extended Kalman Filter
function kebijakan = EKFcustom(kebijakan,param,QF,RF,model) 
global Npop;

beta = param(find(strcmp(model.paramName,'beta')));
gamma = param(find(strcmp(model.paramName,'gamma')));
muI = param(find(strcmp(model.paramName,'muI')));
beta_s = param(find(strcmp(model.paramName,'beta_s')));

% index for easier calling of state variables
S_idx = find(strcmp(model.allStateName,'S'));
Q_idx = find(strcmp(model.allStateName,'Q'));
R_idx = find(strcmp(model.allStateName,'R'));
D_idx = find(strcmp(model.allStateName,'D'));
Q_s_idx = find(strcmp(model.allStateName,'Q_s'));
R_s_idx = find(strcmp(model.allStateName,'R_s'));
D_s_idx = find(strcmp(model.allStateName,'D_s'));

C = zeros(numel(model.fitStateName),numel(model.allStateName));
for i=1:numel(model.fitStateName)
    if(find(strcmp(model.allStateName,model.fitStateName{i})))
        fitIdx = strcmp(model.allStateName,model.fitStateName{i});
        C(i,fitIdx) = 1;
    end
end

tf = numel(kebijakan.timeFit);  % fitting time
dt  = 1;                        % sampling time
tp  = kebijakan.numDays+1;      % prediction time

%% Initialization
xhat = kebijakan.y0'; % initial condition
% Pplus = 1000*eye(numel(model.allStateName)); % since we know exactly the initial conditions
Pplus = eye(numel(model.allStateName));

xArray = []; xhatArray = [];

for f_idx=1:numel(model.fitStateName)
    y(f_idx,:) = kebijakan.(model.fitStateName{f_idx})';
end

% Extended Kalman filter
% for i=1:((tf-1)/dt)
for i=1:((tf)/dt)
    xhatArray    = [xhatArray xhat];     
     
    % State prediction
    xhat(S_idx) = xhat(S_idx) - ((beta*xhat(S_idx)*xhat(Q_idx) + beta_s*xhat(S_idx)*xhat(Q_s_idx))/Npop)*dt;
    xhat(Q_idx) = xhat(Q_idx) + (beta*xhat(S_idx)*xhat(Q_idx)/Npop - (gamma+muI)*xhat(Q_idx))*dt;
    xhat(R_idx) = xhat(R_idx) + gamma*xhat(Q_idx)*dt;
    xhat(D_idx) = xhat(D_idx) + muI*xhat(Q_idx)*dt;
    xhat(Q_s_idx) = xhat(Q_s_idx) + (beta_s*xhat(S_idx)*xhat(Q_s_idx)/Npop - (gamma+muI)*xhat(Q_s_idx))*dt;
    xhat(R_s_idx) = xhat(R_s_idx) + gamma*xhat(Q_s_idx)*dt;
    xhat(D_s_idx) = xhat(D_s_idx) + muI*xhat(Q_s_idx)*dt;
    
    % Calculating the Jacobian matrix A
    A = eye(numel(model.allStateName));
    A(1,1) = 1-(beta*xhat(Q_idx) - beta_s*xhat(Q_s_idx))*dt/Npop;
    A(1,2) = -(beta*xhat(S_idx)/Npop)*dt;
    A(1,5) = -(beta_s*xhat(S_idx)/Npop)*dt;
    A(2,1) = (beta*xhat(Q_idx)/Npop)*dt;
    A(2,2) = 1+(beta*xhat(S_idx)/Npop - (gamma+muI))*dt;
    A(3,2) = gamma*dt;
    A(4,2) = muI*dt;
    A(5,1) = (beta*xhat(Q_s_idx)/Npop)*dt;
    A(5,5) = 1+(beta_s*xhat(S_idx)/Npop - (gamma+muI))*dt;
    A(6,5) = gamma*dt;
    A(7,5) = muI*dt;

    Pmin  = A*Pplus*A' + QF;
    
    % Measurement update 
    KF    = Pmin*C'*inv(C*Pmin*C'+RF);  % Kalman gain
    xhat  = xhat + KF*(y(:,i)-C*xhat);
    Pplus = (eye(numel(model.allStateName))-KF*C)*Pmin;
end

%% Prediction
xp = xhatArray(:,end); xpArray = [];
for i=1:(tp/dt+1)
    xpArray = [xpArray xp];
    xp(S_idx) = xp(S_idx) - ((beta*xp(S_idx)*xp(Q_idx) + beta_s*xp(S_idx)*xp(Q_s_idx))/Npop)*dt;
    xp(Q_idx) = xp(Q_idx) + (beta*xp(S_idx)*xp(Q_idx)/Npop - (gamma+muI)*xp(Q_idx))*dt;
    xp(R_idx) = xp(R_idx) + gamma*xp(Q_idx)*dt;
    xp(D_idx) = xp(D_idx) + muI*xp(Q_idx)*dt;
    xp(Q_s_idx) = xp(Q_s_idx) + (beta_s*xp(S_idx)*xp(Q_s_idx)/Npop - (gamma+muI)*xp(Q_s_idx))*dt;
    xp(R_s_idx) = xp(R_s_idx) + gamma*xp(Q_s_idx)*dt;
    xp(D_s_idx) = xp(D_s_idx) + muI*xp(Q_s_idx)*dt;
end
kebijakan.xhatPredict = [xhatArray xpArray(:,2:end)]';
        
end