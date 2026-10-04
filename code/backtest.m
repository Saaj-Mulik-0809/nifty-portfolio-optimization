%% Step 7: Out-of-sample backtest
clear; clc;
load('returns.mat');
load('opt_weights.mat','rf','maxW');      % reuse the same rf and weight cap

R   = returns{:,1:10};
Rn  = returns{:,11};
names = returns.Properties.VariableNames(1:10);
dates = returns.Time;
n = 10;

%% 1. Split into training (first 60%) and testing (last 40%)
split = round(0.6 * height(returns));
Rtr = R(1:split,:);        Rte = R(split+1:end,:);
Rn_te = Rn(split+1:end);
fprintf('Training: %s to %s (%d days)\n', string(dates(1)), string(dates(split)), split);
fprintf('Testing : %s to %s (%d days)\n\n', string(dates(split+1)), string(dates(end)), height(Rte));

%% 2. Optimize using TRAINING data only
muTr  = mean(Rtr) * 252;
SigTr = cov(Rtr)  * 252;

p = Portfolio('AssetList', names, 'RiskFreeRate', rf);
p = setAssetMoments(p, muTr, SigTr);
p = setDefaultConstraints(p);
p = setBounds(p, 0, maxW);

wMinTr = estimateFrontierLimits(p, 'min');
wMaxTr = estimateMaxSharpeRatio(p);
wEq    = ones(n,1) / n;

disp(table(names', 100*wEq, 100*wMinTr, 100*wMaxTr, ...
    'VariableNames', {'Stock','EqualW_pct','MinVar_pct','MaxSharpe_pct'}));

%% 3. In-sample result for Max Sharpe (training period)
xin = Rtr * wMaxTr;
fprintf('Max Sharpe IN-SAMPLE (training): return %.2f%%, vol %.2f%%, Sharpe %.2f\n\n', ...
    100*mean(xin)*252, 100*std(xin)*sqrt(252), (mean(xin)*252 - rf)/(std(xin)*sqrt(252)));

%% 4. Out-of-sample result (test period), weights held fixed
Pte = [Rte*wEq, Rte*wMinTr, Rte*wMaxTr, Rn_te];
labels = {'Equal weight','Min variance','Max Sharpe','NIFTY50'};

M = zeros(4,4);
for c = 1:4
    x = Pte(:,c);
    ar = mean(x)*252;  av = std(x)*sqrt(252);
    M(c,:) = [ar, av, (ar - rf)/av, maxdd(x)];
end
fprintf('OUT-OF-SAMPLE (test period):\n');
disp(table(labels', 100*M(:,1), 100*M(:,2), M(:,3), 100*M(:,4), ...
    'VariableNames', {'Portfolio','Return_pct','Vol_pct','Sharpe','MaxDrawdown_pct'}));

%% 5. Plot growth of 100 during the test period
figure; hold on; grid on;
plot(dates(split+1:end), 100*cumprod(1+Pte), 'LineWidth', 1.5);
legend(labels, 'Location', 'best');
ylabel('Value of 100 invested at start of test period');
title('Out-of-sample backtest');

%% Helper function (keep at the bottom of the file)
function d = maxdd(x)
    v = [1; cumprod(1 + x)];
    d = min(v ./ cummax(v) - 1);
end