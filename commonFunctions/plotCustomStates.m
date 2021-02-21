function k = plotCustomStates(k,stateNamePlot,model, hFig,cursorMaxIndex)
    global softwareName;
    if(softwareName == 'matlab')
        dcmObj = datacursormode(hFig);
    end
    nameArray = {'Color','LineStyle','linewidth'};
    plotCustEstIndex = [];
    plotCustFitIndex = [];
    for ip=1:numel(stateNamePlot)
        for jp=1:numel(model.allStateName)
            if(strcmp(model.allStateName{jp},stateNamePlot{ip}))
                plotCustEstIndex = [plotCustEstIndex jp];
                if(find(strcmp(model.fitStateName,stateNamePlot{ip})))
                    plotCustFitIndex = [plotCustFitIndex jp];
                end                
            end
        end
    end
    for ik=1:numel(k)
        cursor{ik}.bool = false;
        for jk=1:numel(cursorMaxIndex)
            if(ik == cursorMaxIndex{jk}.kebijakan)
                cursor{ik}.bool = true;
                cursor{ik}.name = cursorMaxIndex{jk}.stateName;
            end
        end
        k{ik} = plotCustomStatesPerKebijakan(k{ik},stateNamePlot,model,cursor{ik});
    end
    
    function kebijakan = plotCustomStatesPerKebijakan(kebijakan,stateNamePlot,model,cursorKebijakan)
        fitLegend = {};
        estLegend = {};
        fitStates = [];
        for i=1:numel(plotCustEstIndex)
            estLegend{i} = [model.allStateName{plotCustEstIndex(i)} ' (estimated)'];
        end
        for i=1:numel(plotCustFitIndex)
            fitLegend{i} = [model.allStateName{plotCustFitIndex(i)} ' (fitting)'];
            fitStates = [fitStates; getfield(kebijakan,model.allStateName{plotCustFitIndex(i)})];
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
        
        set(fitPlot,nameArray,kebijakan.stateLineProp(plotCustFitIndex,:)); grid on;
        hold on
        
        if(softwareName == 'matlab')
            for j=1:numel(kebijakan.timeSim)
              matlabTimeSim(j) = datetime(kebijakan.timeSim{j});
            end
            estPlot = plot(matlabTimeSim,kebijakan.Yest(:,plotCustEstIndex)); 
        else
            for j=1:numel(kebijakan.timeSim)
              epochTimeSim(j) = datenum(kebijakan.timeSim{j});
            end
            estPlot = plot(epochTimeSim,kebijakan.Yest(:,plotCustEstIndex)); 
            datetick('x','dd-mm-yyyy');    
        end
        
        set(estPlot,nameArray,kebijakan.stateLineProp(plotCustEstIndex,:)); grid on;
        hold on
        kebijakan.plotHandler = [fitPlot' estPlot'];
        kebijakan.varName = [fitLegend estLegend];
        
%         if(cursorKebijakan.bool)
%             kebijakan.peak{cIdx}.name = cursorKebijakan.name{cIdx};
%             kebijakan.peak.y = max(kebijakan.Yest(:,find(strcmp(model.allStateName,cursorKebijakan.name{cIdx}))));
%             kebijakan.peak.x = find(kebijakan.Yest(:,find(strcmp(model.allStateName,cursorKebijakan.name{cIdx})))==kebijakan.peak.y);
%             hLine = estPlot(find(strcmp(stateNamePlot,cursorKebijakan.name)));
%             if(softwareName == 'matlab')
%                 cursorKebijakan.dTip = createDatatip(dcmObj,hLine);
%                 cursorKebijakan.dTip.Position = [kebijakan.peak.x kebijakan.peak.y 0];
%             end
%         end
        if(cursorKebijakan.bool)
            kebijakan.peak = {};
            for cIdx=1:numel(cursorKebijakan.name)
                kebijakan.peak{cIdx}.name = cursorKebijakan.name{cIdx};
                [kebijakan.peak{cIdx}.y kebijakan.peak{cIdx}.x] = max(kebijakan.Yest(:,find(strcmp(model.allStateName,cursorKebijakan.name{cIdx}))));
                hLine = estPlot(find(strcmp(stateNamePlot,cursorKebijakan.name{cIdx})));
                if(softwareName == 'matlab')
                    cursorKebijakan.dTip{cIdx} = createDatatip(dcmObj,hLine);
%                     cursorKebijakan.dTip{cIdx}.Position = [kebijakan.peak{cIdx}.x kebijakan.peak{cIdx}.y 0];
                    if(kebijakan.peak{cIdx}.y <= 0)
                        cursorKebijakan.dTip{cIdx}.Position = [1 kebijakan.peak{cIdx}.y 0];
                    else
                        cursorKebijakan.dTip{cIdx}.Cursor.DataIndex = kebijakan.peak{cIdx}.x;  
                    end
                end
            end
        end
    end
end