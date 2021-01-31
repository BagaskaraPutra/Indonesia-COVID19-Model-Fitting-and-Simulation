function [fit, pred] = fitMAE(k,val,model,rfi)
% initialize fit and estimated data array
for fIdx = 1:numel(model.fitStateName)
    fit.yMeas.(model.fitStateName{fIdx}) = [];
    fit.yHat.(model.fitStateName{fIdx}) = [];
    pred.yMeas.(model.fitStateName{fIdx}) = [];
    pred.yHat.(model.fitStateName{fIdx}) = [];
end

% fitting section
for kIdx=1:rfi
    % concatenate fitting and estimation data based on start & end date
    for fIdx=1:numel(model.fitStateName)
        fit.yMeas.(model.fitStateName{fIdx}) = [fit.yMeas.(model.fitStateName{fIdx}) ...
            k{kIdx}.(model.fitStateName{fIdx})];
        fit.yHat.(model.fitStateName{fIdx}) = [fit.yHat.(model.fitStateName{fIdx}); ...
            k{kIdx}.Yest(...
            1:numel(k{kIdx}.(model.fitStateName{fIdx})),...
            (find(strcmp(model.allStateName,model.fitStateName{fIdx})))...
                     ) ...
            ];
    end
end

% prediction section
% find date index of validation data 
for tIdx=1:numel(k{rfi}.timeSim)
    if(k{rfi}.timeSim{tIdx} == val.timeFit{1})
        vStart = tIdx;
    end
    if(k{rfi}.timeSim{tIdx} == val.timeFit{end})
        vEnd = tIdx;
    end
end
% concatenate fitting and estimation data based on start & end date
for fIdx=1:numel(model.fitStateName)
    pred.yMeas.(model.fitStateName{fIdx}) = [pred.yMeas.(model.fitStateName{fIdx}) ... 
        val.(model.fitStateName{fIdx})];
    pred.yHat.(model.fitStateName{fIdx}) = [pred.yHat.(model.fitStateName{fIdx}); ...
        k{rfi}.Yest(...
        vStart:vEnd,...
        (find(strcmp(model.allStateName,model.fitStateName{fIdx})))...
                    ) ...
                ];
end

% calculate MAE
fit.MAEsum = 0; pred.MAEsum = 0;
for rIdx = 1:numel(model.fitStateName)
    fit.MAE.(model.fitStateName{rIdx}) = MAE(fit.yMeas.(model.fitStateName{rIdx})', fit.yHat.(model.fitStateName{rIdx}));
    pred.MAE.(model.fitStateName{rIdx}) = MAE(pred.yMeas.(model.fitStateName{rIdx})', pred.yHat.(model.fitStateName{rIdx}));
    fit.MAEsum = fit.MAEsum + fit.MAE.(model.fitStateName{rIdx});
    pred.MAEsum = pred.MAEsum + pred.MAE.(model.fitStateName{rIdx});
end
fit.MAEavg = fit.MAEsum/numel(fieldnames(fit.MAE));
pred.MAEavg = pred.MAEsum/numel(fieldnames(pred.MAE));

%     function MAEResult = MAE(y, yhat)
%         MAEResult = sqrt(mean((y - yhat).^2));  % Root Mean Squared Error
%     end

end