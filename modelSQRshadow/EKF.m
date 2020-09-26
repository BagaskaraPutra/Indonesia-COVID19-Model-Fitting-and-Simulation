% Function Extended Kalman Filter
function kebijakan = EKF(kebijakan,param,QF,RF,model) 
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

tf = numel(kebijakan.timeFit);
dt  = 0.01;                     % time steps
t   = dt:dt:tf;
tp  = kebijakan.numDays+1; %90; % prediction time

%% Noise
% QF = diag([10 10 10 10 10 10 10]);   % process and measurement covariance matrices
% RF = diag([10 1 1]);       % are considered as tuning parameters

%% For plotting
%% Initialization
%     xhat     = [N-1; 1; 0; 0; 1; 0];   % initial condition
xhat = kebijakan.y0';
Pplus    = 1000*eye(numel(model.allStateName)); % since we know excatly the initial conditions
xhatEff  = 0;
% for plotting
xArray       = [];
xhatArray    = [];
xhatEffArray = [];
% extended Kalman filter
for i=1:((tf-1)/dt)
     xhatArray    = [xhatArray xhat]; 
     xhatEffArray = [xhatEffArray xhatEff];      
     % assimilating the reported data
%      y = [interp1(0:1:tf-1,DATA(:,3),t);
%          interp1(0:1:tf-1,DATA(:,4),t);
%          interp1(0:1:tf-1,DATA(:,5),t);
%          interp1(0:1:tf-1,DATA(:,6),t);
%          interp1(0:1:tf-1,DATA(:,7),t)];
     for i=1:numel(model.fitStateName)
%          y(i,:) = interp1(0:1:tf-1,kebijakan.(model.fitStateName{i})',t);
        y(i,:) = kebijakan.(model.fitStateName{i})';
     end

     % prediction
     xhat(S_idx) = xhat(S_idx) - ((beta*xhat(S_idx)*xhat(Q_idx) + beta_s*xhat(S_idx)*xhat(Q_s_idx))/Npop)*dt;
     xhat(Q_idx) = xhat(Q_idx) + (beta*xhat(S_idx)*xhat(Q_idx)/Npop - (gamma+muI)*xhat(Q_idx))*dt;
     xhat(R_idx) = xhat(R_idx) + gamma*xhat(Q_idx)*dt;
     xhat(D_idx) = xhat(D_idx) + muI*xhat(Q_idx)*dt;
     xhat(Q_s_idx) = xhat(Q_s_idx) + (beta_s*xhat(S_idx)*xhat(Q_s_idx)/Npop - (gamma+muI)*xhat(Q_s_idx))*dt;
     xhat(R_s_idx) = xhat(R_s_idx) + gamma*xhat(Q_s_idx)*dt;
     xhat(D_s_idx) = xhat(D_s_idx) + muI*xhat(Q_s_idx)*dt;
    
    % calculating the Jacobian matrix
    FX = eye(numel(model.allStateName));
    FX(1,1) = 1-(beta*xhat(Q_idx) - beta_s*xhat(Q_s_idx))*dt/Npop;
    FX(1,2) = -(beta*xhat(S_idx)/Npop)*dt;
    FX(1,5) = -(beta_s*xhat(S_idx)/Npop)*dt;
    FX(2,1) = (beta*xhat(Q_idx)/Npop)*dt;
    FX(2,2) = 1+(beta*xhat(S_idx)/Npop - (gamma+muI))*dt;
    FX(3,2) = gamma*dt;
    FX(4,2) = muI*dt;
    FX(5,1) = (beta*xhat(Q_s_idx)/Npop)*dt;
    FX(5,5) = 1+(beta_s*xhat(S_idx)/Npop - (gamma+muI))*dt;
    FX(6,5) = gamma*dt;
    FX(7,5) = muI*dt;

    Pmin  = FX*Pplus*FX'+QF;
    % update 
    KF    = Pmin*C'*inv(C*Pmin*C'+RF);  % Kalman gain
    xhat  = xhat + KF*(y(:,i)-C*xhat);
    Pplus = (eye(numel(model.allStateName))-KF*C)*Pmin;
    xhat(numel(model.allStateName)) = max(0,xhat(numel(model.allStateName)));           % the reproduction number cannot be negative
end

%% Plotting

% xhatArray(numel(model.allStateName),:) = filter(b,a,xhatEffArray);

% xhatSArray  = []; xhatS       = xhatArray(1,tf);
% xhatIArray  = []; xhatI       = xhatArray(2,tf);
% xhatRArray  = []; xhatR       = xhatArray(3,tf);
% xhatDArray  = []; xhatD       = xhatArray(4,tf);
% xhatHArray  = []; xhatH       = xhatArray(5,tf);
% xhatRtArray = []; xhatRt      = xhatArray(6,tf);
xhatVarArray = double.empty(numel(model.allStateName),0);
for i=1:numel(model.allStateName)
    xhatVar(i,:) = xhatArray(i,tf); %xhatArray(i,tf); 
end

for i=1:tf-1
%     xhatSArray  = [xhatSArray xhatS]; xhatS       = xhatArray(1,(1/dt)*i);
%     xhatIArray  = [xhatIArray xhatI]; xhatI       = xhatArray(2,(1/dt)*i);
%     xhatRArray  = [xhatRArray xhatR]; xhatR       = xhatArray(3,(1/dt)*i);
%     xhatDArray  = [xhatDArray xhatD]; xhatD       = xhatArray(4,(1/dt)*i);
%     xhatHArray  = [xhatHArray xhatH]; xhatH       = xhatArray(5,(1/dt)*i);
%     xhatRtArray = [xhatRtArray xhatRt]; xhatRt      = xhatArray(6,(1/dt)*i);
    xhatVarArray = [xhatVarArray xhatVar];
    xhatVar = xhatArray(:, (1/dt)*i);
end

% xhatSArray  = [xhatSArray xhatS];
% xhatIArray  = [xhatIArray xhatI];
% xhatRArray  = [xhatRArray xhatR];
% xhatDArray  = [xhatDArray xhatD];
% xhatHArray  = [xhatHArray xhatH];
% xhatRtArray = [xhatRtArray xhatRt];
xhatVarArray = [xhatVarArray xhatVar];

%% Forecasting
%         xp   = [DATA(end,3); DATA(end,4); DATA(end,5); DATA(end,6); DATA(end,7)]; % initial condition
        xp = xhatVarArray(:,end);
        xpArray = [];
        
        for i=1:tp/dt
            xpArray = [xpArray xp];
             xp(S_idx) = xp(S_idx) - ((beta*xp(S_idx)*xp(Q_idx) + beta_s*xp(S_idx)*xp(Q_s_idx))/Npop)*dt;
             xp(Q_idx) = xp(Q_idx) + (beta*xp(S_idx)*xp(Q_idx)/Npop - (gamma+muI)*xp(Q_idx))*dt;
             xp(R_idx) = xp(R_idx) + gamma*xp(Q_idx)*dt;
             xp(D_idx) = xp(D_idx) + muI*xp(Q_idx)*dt;
             xp(Q_s_idx) = xp(Q_s_idx) + (beta_s*xp(S_idx)*xp(Q_s_idx)/Npop - (gamma+muI)*xp(Q_s_idx))*dt;
             xp(R_s_idx) = xp(R_s_idx) + gamma*xp(Q_s_idx)*dt;
             xp(D_s_idx) = xp(D_s_idx) + muI*xp(Q_s_idx)*dt;
        end
        
%         xpSArray  = []; xpS = xpArray(1,tf);
%         xpIArray  = []; xpI = xpArray(2,tf);
%         xpRArray  = []; xpR = xpArray(3,tf);
%         xpDArray  = []; xpD = xpArray(4,tf);
%         xpHArray  = []; xpH = xpArray(5,tf);
        xpVarArray = double.empty(numel(model.allStateName),0);
        for i=1:numel(model.allStateName)
            xpVar(i,:) = xpArray(i,tf); 
        end
        
        for i=1:tp
%             xpSArray  = [xpSArray xpS]; xpS       = xpArray(1,(1/dt)*i);
%             xpIArray  = [xpIArray xpI]; xpI       = xpArray(2,(1/dt)*i);
%             xpRArray  = [xpRArray xpR]; xpR       = xpArray(3,(1/dt)*i);
%             xpDArray  = [xpDArray xpD]; xpD       = xpArray(4,(1/dt)*i);
%             xpHArray  = [xpHArray xpH]; xpH       = xpArray(5,(1/dt)*i);
                xpVarArray = [xpVarArray xpVar];
                xpVar = xpArray(:, (1/dt)*i);
        end
        
%         xIpredic(m,:) = [xhatIArray xpIArray];
%         xRpredic(m,:) = [xhatRArray xpRArray];
%         xDpredic(m,:) = [xhatDArray xpDArray];
%         xHpredic(m,:) = [xhatHArray xpHArray];   
          kebijakan.xVarPredic = [xhatVarArray xpVarArray]';
    
end