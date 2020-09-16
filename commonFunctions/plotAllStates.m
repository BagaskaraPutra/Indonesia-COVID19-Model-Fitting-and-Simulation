function k = plotAllStates(k,model, hFig,cursorMaxIndex)
    global softwareName;
    if(softwareName == 'matlab')
        dcmObj = datacursormode(hFig);
    end
    nameArray = {'Color','LineStyle','linewidth'};
    for ik=1:numel(k)
        cursor{ik}.bool = false;
        for jk=1:numel(cursorMaxIndex)
            if(ik == cursorMaxIndex{jk}.kebijakan)
                cursor{ik}.bool = true;
                cursor{ik}.name = cursorMaxIndex{jk}.stateName;
            end
        end
        k{ik} = plotAllStatesPerKebijakan(k{ik},model,cursor{ik});
    end

    function kebijakan = plotAllStatesPerKebijakan(kebijakan,model,cursorKebijakan)
        fitStates = [];
        for i=1:numel(model.fitStateName)
            fitStates = [fitStates; getfield(kebijakan,model.fitStateName{i})];
        end
        
        if(softwareName == 'matlab')
            for j=1:numel(kebijakan.timeFit)
              matlabTimeFit(j) = datetime(kebijakan.timeFit{j});
            end
            fitPlot = plot(matlabTimeFit,fitStates,'o','linewidth',1.5); 
        else
            for j=1:numel(kebijakan.timeFit)
              epochTimeFit(j) = datenum(kebijakan.timeFit{j});
            end
            fitPlot = plot(epochTimeFit,fitStates,'o','linewidth',1.5); 
            datetick('x','dd-mm-yyyy');    
        end
        
        fitIndex = [];
        for i=1:numel(model.fitStateName)
            for j=1:numel(model.allStateName)
                if(strcmp(model.allStateName{j},model.fitStateName{i}))
                    fitIndex = [fitIndex j];
                end
            end
        end
        set(fitPlot,nameArray,kebijakan.stateLineProp(fitIndex,:)); grid on;
        hold on
        
        if(softwareName == 'matlab')
            for j=1:numel(kebijakan.timeSim)
              matlabTimeSim(j) = datetime(kebijakan.timeSim{j});
            end
            estPlot = plot(matlabTimeSim,kebijakan.Yest); 
        else
            for j=1:numel(kebijakan.timeSim)
              epochTimeSim(j) = datenum(kebijakan.timeSim{j});
            end
            estPlot = plot(epochTimeSim,kebijakan.Yest); 
            datetick('x','dd-mm-yyyy');
        end
                
        set(estPlot,nameArray,kebijakan.stateLineProp); grid on;
        hold on
        kebijakan.plotHandler = [fitPlot' estPlot'];
        fittingLegend = {};
        for i=1:numel(model.fitStateName)
            fittingLegend{i} = [model.fitStateName{i} ' (fitting)'];
        end
        estLegend = {};
        for i=1:numel(model.allStateName)
            estLegend{i} = [model.allStateName{i} ' (estimated)'];
        end
        kebijakan.varName = [fittingLegend estLegend];
        
        if(cursorKebijakan.bool)
            kebijakan.peak.y = max(kebijakan.Yest(:,find(strcmp(model.allStateName,cursorKebijakan.name))));
            kebijakan.peak.x = find(kebijakan.Yest(:,find(strcmp(model.allStateName,cursorKebijakan.name)))==kebijakan.peak.y);
            hLine = estPlot(find(strcmp(model.allStateName,cursorKebijakan.name)));
            if(softwareName == 'matlab')
                cursorKebijakan.dTip = createDatatip(dcmObj,hLine);
                cursorKebijakan.dTip.Position = [kebijakan.peak.x kebijakan.peak.y 0];
            end
        end
    end
end