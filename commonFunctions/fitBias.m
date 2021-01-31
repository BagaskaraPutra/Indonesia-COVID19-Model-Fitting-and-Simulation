function [fit, pred] = fitBias(k,val,model,rfi)
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

% calculate Bias
fit.Biassum = 0; pred.Biassum = 0;
for rIdx = 1:numel(model.fitStateName)
    fit.Bias.(model.fitStateName{rIdx}) = Bias(fit.yMeas.(model.fitStateName{rIdx})', fit.yHat.(model.fitStateName{rIdx}));
    pred.Bias.(model.fitStateName{rIdx}) = Bias(pred.yMeas.(model.fitStateName{rIdx})', pred.yHat.(model.fitStateName{rIdx}));
    fit.Biassum = fit.Biassum + fit.Bias.(model.fitStateName{rIdx});
    pred.Biassum = pred.Biassum + pred.Bias.(model.fitStateName{rIdx});
end
fit.Biasavg = fit.Biassum/numel(fieldnames(fit.Bias));
pred.Biasavg = pred.Biassum/numel(fieldnames(pred.Bias));

%     function BiasResult = Bias(y, yhat)
%         BiasResult = sqrt(mean((y - yhat).^2));  % Root Mean Squared Error
%     end

end