function [kebijakan,varargout] = fitModel(kebijakan,model,varargin)
% estimates the parameters 
%   time: vector [1xN] of time (datetime)
%   guess: first vector guess for the fit
%   optionals
%       -tolFun: tolerance  option for optimset
%       -tolX: tolerance  option for optimset
%       -Display: Display option for optimset
%       -dt: time step for the fitting function
%       - residual
%       - Jacobian
%       - The function @model_for_fitting
% Author: E. Cheynet - UiB - last modified 24-03-2020
% modified: Bagaskara P.P. - last modified 06-09-2020

fprintf(['Estimating ' kebijakan.name '\n']);

%% Fitting of the model to the real data
dt = 1; %0.1; % time step
timeTotal = numel(kebijakan.timeFit);
dataFit = [];
for i=1:numel(model.fitStateName)
    dataFit = [dataFit; kebijakan.(model.fitStateName{i})];
end
tspan = [0:timeTotal-1].*dt;

%% Inputparser
p = inputParser();
p.CaseSensitive = false;
p.addOptional('tolX',kebijakan.tolX); %8.8e-9); %1e-12);  %  option for optimset
p.addOptional('tolFun',kebijakan.tolFun); %8.8e-9); %1e-12);  %  option for optimset
p.addOptional('Display','iter'); % Display option for optimset
p.addOptional('dt',dt); % time step for the fitting
p.parse(varargin{:});
%%%%%%%%%%%%%%%%%%%%%%%%%%
tolX = p.Results.tolX ;
tolFun = p.Results.tolFun ;
Display  = p.Results.Display ;

%% Options for lsqcurvfit
optionslsq=optimset('TolX',tolX,'TolFun',tolFun,'MaxFunEvals',1e4,'MaxIter',1e4,'Display',Display);

%% Fitting the data
if size(kebijakan.timeFit,1)>size(kebijakan.timeFit,2) && size(kebijakan.timeFit,2)==1,    kebijakan.timeFit = kebijakan.timeFit';end
if size(kebijakan.timeFit,1)>1 && size(kebijakan.timeFit,2)>1,  error('Time should be a vector');end

fs = 1./dt;
for i=1:numel(kebijakan.timeFit)
  timeFitInterval(i) = datenum(kebijakan.timeFit{i})-datenum(kebijakan.timeFit{1});
end
tTarget = round(timeFitInterval*fs)/fs; % Number of days with one decimal 

t = tTarget(1):dt:tTarget(end); % oversample to ensure that the algorithm converges

cd(model.dir);
modelFun1 = @model_for_fitting; % transform a nested function into anonymous function

% call Lsqcurvefit
[Coeff,~,residual,~,~,~,jacobian] = lsqcurvefit(@(para,t) modelFun1(para,t),...
                                                kebijakan.guessParam,...
                                                tTarget(:)',...
                                                dataFit,....
                                                kebijakan.lbParam,...
                                                kebijakan.ubParam,...
                                                optionslsq);

%% Write the fitted coeff in the outputs
for p=1:numel(kebijakan.guessParam)
    kebijakan.paramEst(p) = abs(Coeff(p));
end

%% nested functions
    function [output] = model_for_fitting(para,t0)
        paramOde = [];
        for i=1:numel(kebijakan.guessParam)
            paramOde = [paramOde abs(para(i))];
        end
        
        %% Initial conditions
        N = numel(t);
        options = odeset('RelTol',1e-6, 'AbsTol',1e-8, 'InitialStep',0.01, 'NonNegative',1);
        [T,Y] = ode45(@fOde, tspan, kebijakan.y0, options, paramOde);
        fitIndex = [];
        for i=1:numel(model.fitStateName)
            for j=1:numel(model.allStateName)
%                 if(model.allStateName{j} ==  model.fitStateName{i})
                if(strcmp(model.allStateName{j},model.fitStateName{i}))
                    fitIndex = [fitIndex j];
                end
            end
        end
        for i=1:numel(model.fitStateName)
            fitState(:,i) = Y(:,fitIndex(i));
        end
        for i=1:numel(model.fitStateName)
            fitState(:,i) = interp1(t,fitState(:,i),t0);
            output(i,:) =fitState(:,i)';
        end
    end
end