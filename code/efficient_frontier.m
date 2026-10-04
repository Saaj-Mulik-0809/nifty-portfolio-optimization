%% Step 5: Efficient frontier, min-variance, max-Sharpe
clear; clc;
load('returns.mat');
R = returns{:,1:10};
names = returns.Properties.VariableNames(1:10);
n = 10;

mu    = mean(R) * 252;
Sigma = cov(R)  * 252;
vols  = sqrt(diag(Sigma))';

rf   = 0.072;      % risk-free rate: CHECK the current Indian 10Y yield and edit
maxW = 0.30;       % max weight in any single stock

%% 1. Build the portfolio problem
p = Portfolio('AssetList', names, 'RiskFreeRate', rf);
p = setAssetMoments(p, mu, Sigma);
p = setDefaultConstraints(p);        % no short selling, weights add to 100%
p = setBounds(p, 0, maxW);           % each stock between 0% and maxW

%% 2. Compute the frontier and the two special portfolios
wFront = estimateFrontier(p, 30);                 % 30 points along the frontier
[fRisk, fRet] = estimatePortMoments(p, wFront);

wMin = estimateFrontierLimits(p, 'min');          % minimum-variance portfolio
wMax = estimateMaxSharpeRatio(p);                 % maximum-Sharpe portfolio
wEq  = ones(n,1) / n;                             % equal weight, for comparison

%% 3. Compare portfolios
Rn = returns{:,11};                               % NIFTY50
niftyRet = mean(Rn)*252;  niftyVol = std(Rn)*sqrt(252);

pr = @(w) mu*w;
pv = @(w) sqrt(w'*Sigma*w);
labels = {'Equal weight'; 'Min variance'; 'Max Sharpe'; 'NIFTY50'};
rets_ = 100*[pr(wEq); pr(wMin); pr(wMax); niftyRet];
vols_ = 100*[pv(wEq); pv(wMin); pv(wMax); niftyVol];
sharp = (rets_/100 - rf) ./ (vols_/100);
disp(table(labels, rets_, vols_, sharp, ...
    'VariableNames', {'Portfolio','Return_pct','Vol_pct','Sharpe'}));

%% 4. Weights
disp(table(names', 100*wEq, 100*wMin, 100*wMax, ...
    'VariableNames', {'Stock','EqualW_pct','MinVar_pct','MaxSharpe_pct'}));
save('opt_weights.mat','wEq','wMin','wMax','mu','Sigma','rf','maxW','names');

%% 5. Plot: random cloud + frontier + special portfolios
rng(1); N = 5000; rr = zeros(N,1); rk = zeros(N,1);
for k = 1:N
    x = rand(n,1).^3;  w = x/sum(x);
    rr(k) = mu*w;  rk(k) = sqrt(w'*Sigma*w);
end
figure; hold on; grid on;
scatter(100*rk, 100*rr, 6, [0.6 0.6 0.9], 'filled', 'MarkerFaceAlpha', 0.3);
plot(100*fRisk, 100*fRet, 'k-', 'LineWidth', 2.5);
scatter(100*vols, 100*mu, 50, 'r', 'filled');
scatter(100*pv(wEq),  100*pr(wEq),  150, 'y', 'p', 'filled');
scatter(100*pv(wMin), 100*pr(wMin), 120, 'g', 'd', 'filled');
scatter(100*pv(wMax), 100*pr(wMax), 150, 'm', 'o', 'filled');
xlabel('Risk: annual volatility (%)'); ylabel('Return: annual (%)');
title('Efficient frontier (max 30% per stock)');
legend('Random portfolios','Efficient frontier','Single stocks', ...
       'Equal weight','Min variance','Max Sharpe','Location','southeast');

%% 6. Weight bar chart
figure;
bar(100*[wMin wMax]);
set(gca,'XTickLabel',names); xtickangle(45);
legend('Min variance','Max Sharpe'); ylabel('Weight (%)'); grid on;
title('Optimal portfolio weights');