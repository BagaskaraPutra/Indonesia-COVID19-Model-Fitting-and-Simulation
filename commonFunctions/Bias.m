function biasResult = Bias(y, yhat)
    biasResult = mean(yhat - y);  % Root Mean Squared Error
end