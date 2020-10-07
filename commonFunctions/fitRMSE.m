function [fit, pred] = fitRMSE(k,val,model,rfi)
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

% calculate RMSE
fit.RMSEsum = 0; pred.RMSEsum = 0;
for rIdx = 1:numel(model.fitStateName)
    fit.RMSE.(model.fitStateName{rIdx}) = RMSE(fit.yMeas.(model.fitStateName{rIdx})', fit.yHat.(model.fitStateName{rIdx}));
    pred.RMSE.(model.fitStateName{rIdx}) = RMSE(pred.yMeas.(model.fitStateName{rIdx})', pred.yHat.(model.fitStateName{rIdx}));
    fit.RMSEsum = fit.RMSEsum + fit.RMSE.(model.fitStateName{rIdx});
    pred.RMSEsum = pred.RMSEsum + pred.RMSE.(model.fitStateName{rIdx});
end
fit.RMSEavg = fit.RMSEsum/numel(fieldnames(fit.RMSE));
pred.RMSEavg = pred.RMSEsum/numel(fieldnames(pred.RMSE));

%     function rmseResult = RMSE(y, yhat)
%         rmseResult = sqrt(mean((y - yhat).^2));  % Root Mean Squared Error
%     end

end