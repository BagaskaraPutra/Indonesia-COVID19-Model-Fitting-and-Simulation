function saveTimeSeries(kebijakan,saveDir,model)
for i=1:numel(kebijakan)
    fid=fopen([saveDir '/' num2str(i) '. ' kebijakan{i}.name '.csv'],'w');
    fprintf(fid,'datetime,');
    for simAll=1:numel(model.allStateName)
        if(simAll == numel(model.allStateName))
            fprintf(fid,[model.allStateName{simAll} '\n']);
        else
            fprintf(fid,[model.allStateName{simAll} ',']);
        end
    end
    for rowSim=1:numel(kebijakan{i}.timeSim)
        fprintf(fid,[datestr(kebijakan{i}.timeSim{rowSim}) ',']);
        for colSim = 1:numel(model.allStateName)
            if(colSim == numel(model.allStateName))
                fprintf(fid,[num2str(round(kebijakan{i}.Yest(rowSim,colSim))) '\n']);
            else
                fprintf(fid,[num2str(round(kebijakan{i}.Yest(rowSim,colSim))) ',']);
            end 
        end   
    end
end