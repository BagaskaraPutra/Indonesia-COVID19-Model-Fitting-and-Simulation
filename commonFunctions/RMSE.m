function rmseResult = RMSE(y, yhat)
    rmseResult = sqrt(mean((y - yhat).^2));  % Root Mean Squared Error
end