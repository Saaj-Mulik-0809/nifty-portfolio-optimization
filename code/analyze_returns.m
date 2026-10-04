%% Step 3: Returns, volatility, correlation
clear; clc;
load('prices.mat');                      % loads the timetable 'prices'

allNames   = prices.Properties.VariableNames;   % 10 stocks + NIFTY50
stockNames = allNames(1:10);

%% 1. Daily returns
R = tick2ret(prices{:,:});               % simple returns, 1234 x 11 matrix
returns = array2timetable(R, 'RowTimes', prices.Time(2:end), ...
                          'VariableNames', allNames);
save('returns.mat','returns');
fprintf('Number of daily returns: %d\n\n', height(returns));

%% 2. Sanity check: biggest one-day moves (spot data errors)
fprintf('Biggest daily gain and loss per asset (%%):\n');
disp(table(allNames', 100*max(R)', 100*min(R)', ...
    'VariableNames', {'Asset','BestDay','WorstDay'}));

%% 3. Annualized return and volatility
dailyMean = mean(R);
dailyStd  = std(R);
annRet = dailyMean * 252;
annVol = dailyStd  * sqrt(252);

summary = table(allNames', 100*annRet', 100*annVol', ...
    'VariableNames', {'Asset','AnnReturn_pct','AnnVol_pct'});
disp(summary);

%% 4. Correlation matrix of the 10 stocks
C = corr(R(:,1:10));
figure;
heatmap(stockNames, stockNames, C, 'CellLabelFormat','%.2f', ...
        'Colormap', parula);
title('Correlation of daily returns');

%% 5. Which pairs are most / least correlated?
C_off = C - 2*eye(10);                   % push the diagonal (self-correlation) out of the way
[maxVal, idx] = max(C_off(:));
[i,j] = ind2sub(size(C), idx);
fprintf('Most correlated pair : %s & %s = %.2f\n', stockNames{i}, stockNames{j}, maxVal);

C_off2 = C + 2*eye(10);
[minVal, idx] = min(C_off2(:));
[i,j] = ind2sub(size(C), idx);
fprintf('Least correlated pair: %s & %s = %.2f\n', stockNames{i}, stockNames{j}, minVal);