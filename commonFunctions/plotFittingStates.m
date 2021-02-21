function k = plotFittingStates(k,model, hFig,cursorMaxIndex)
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
        k{ik} = plotFittingStatesPerKebijakan(k{ik},model,cursor{ik});
    end

    function kebijakan = plotFittingStatesPerKebijakan(kebijakan,model,cursorKebijakan)
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
            estPlot = plot(matlabTimeSim,kebijakan.Yest(:,fitIndex));
        else
            for j=1:numel(kebijakan.timeSim)
              epochTimeSim(j) = datenum(kebijakan.timeSim{j});
            end
            estPlot = plot(epochTimeSim,kebijakan.Yest(:,fitIndex));
            datetick('x','dd-mm-yyyy');
        end

        set(estPlot,nameArray,kebijakan.stateLineProp(fitIndex,:)); grid on;
        hold on
        kebijakan.plotHandler = [fitPlot' estPlot'];
        fittingLegend = {};
        estLegend = {};
        for i=1:numel(model.fitStateName)
            fittingLegend{i} = [model.fitStateName{i} ' (fitting)'];
            estLegend{i} = [model.fitStateName{i} ' (estimated)'];
        end
        kebijakan.varName = [fittingLegend estLegend];
        
        if(cursorKebijakan.bool)
            kebijakan.peak = {};
            for cIdx=1:numel(cursorKebijakan.name)
                kebijakan.peak{cIdx}.name = cursorKebijakan.name{cIdx};
                [kebijakan.peak{cIdx}.y kebijakan.peak{cIdx}.x] = max(kebijakan.Yest(:,find(strcmp(model.allStateName,cursorKebijakan.name{cIdx}))));
                if(isempty(find(strcmp(model.fitStateName,cursorKebijakan.name{cIdx}))) )
                    break;
                end
                hLine = estPlot(find(strcmp(model.fitStateName,cursorKebijakan.name{cIdx})));
                if(softwareName == 'matlab')
                    cursorKebijakan.dTip{cIdx} = createDatatip(dcmObj,hLine);
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
