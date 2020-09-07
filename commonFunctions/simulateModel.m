function kebijakan = simulateModel(kebijakan,param,model)
global softwareName;
%% Simulate the epidemy outbreak based on the fitted parameters
dt = 1; %0.1; % time step
if(isfield(kebijakan,'endDate'))
  endOfDateIter = findIndexFromCell(kebijakan.timeFit,datetime(kebijakan.endDate)) + datenum(0,0,kebijakan.numDays)+1;
  if(softwareName == 'matlab')
     for i=1:endOfDateIter
        kebijakan.timeSim{i} = datetime(kebijakan.startDate) + datenum(0,0,i-1);
     end 
%      kebijakan.timeSim = datetime(kebijakan.startDate):dt:datetime(datestr(floor(datenum(kebijakan.endDate))+datenum(kebijakan.numDays)));
  else
     for i=1:endOfDateIter
        kebijakan.timeSim{i} = datetime(datenum(kebijakan.startDate) + datenum(0,0,i-1));
     end 
  end
else
    if(numel(kebijakan.timeFit) > 1)
      endOfDateIter = numel(kebijakan.timeFit) + datenum(0,0,kebijakan.numDays)+1;
      if(softwareName == 'matlab')
         for i=1:endOfDateIter
            kebijakan.timeSim{i} = datetime(kebijakan.startDate) + datenum(0,0,i-1);
         end 
%           kebijakan.timeSim = datetime(kebijakan.startDate):dt:datetime(datestr(floor(datenum(kebijakan.timeFit{end}))+datenum(kebijakan.numDays)));
      else
          for i=1:endOfDateIter
            kebijakan.timeSim{i} = datetime(datenum(kebijakan.startDate) + datenum(0,0,i-1));
          end
      end
    else
      endOfDateIter = datenum(0,0,kebijakan.numDays)+1;  
      if(softwareName == 'matlab')
         for i=1:endOfDateIter
            kebijakan.timeSim{i} = datetime(kebijakan.startDate) + datenum(0,0,i-1);
         end 
%           kebijakan.timeSim = datetime(kebijakan.startDate):dt:datetime(kebijakan.startDate)+datenum(0,0,kebijakan.numDays);
      else
          for i=1:endOfDateIter
            kebijakan.timeSim{i} = datetime(datenum(kebijakan.startDate) + datenum(0,0,i-1));
          end    
      end
    end
end
N = numel(kebijakan.timeSim);
t = [0:N-1].*dt;
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8, 'InitialStep', 0.01);
cd(model.dir);
[kebijakan.Test,kebijakan.Yest] = ode45(@fOde, t, kebijakan.y0, options, param);