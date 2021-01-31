function rmseResult = MAE(y, yhat)
    rmseResult = mean(abs(y - yhat));  % Mean Absolute Error
end