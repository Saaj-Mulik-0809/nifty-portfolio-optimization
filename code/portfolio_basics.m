%% Step 4: Portfolio return and risk
clear; clc;
load('returns.mat');
R = returns{:,1:10};                         % 10 stocks only (no index)
names = returns.Properties.VariableNames(1:10);
n = 10;

mu    = mean(R) * 252;                       % 1x10 annual returns
Sigma = cov(R)  * 252;                       % 10x10 annual covariance matrix
vols  = sqrt(diag(Sigma))';                  % 1x10 annual volatilities

%% 1. Equal-weight portfolio
w = ones(n,1) / n;
pRet = mu * w;
pVol = sqrt(w' * Sigma * w);

fprintf('Equal-weight portfolio\n');
fprintf('  Return    : %.2f%%\n', 100*pRet);
fprintf('  Volatility: %.2f%%\n', 100*pVol);
fprintf('  Plain average of the 10 individual volatilities: %.2f%%\n', 100*mean(vols));
fprintf('  Risk removed by diversification: %.2f percentage points\n\n', 100*(mean(vols)-pVol));

%% 2. 5000 random portfolios
rng(1);                                      % makes results repeatable
N = 5000;
rets = zeros(N,1);  risks = zeros(N,1);
for k = 1:N
    x = rand(n,1).^3;                        % cubing spreads weights out for more variety
    w = x / sum(x);                          % scale so weights add to 100%
    rets(k)  = mu * w;
    risks(k) = sqrt(w' * Sigma * w);
end

%% 3. Plot
figure; hold on; grid on;
scatter(100*risks, 100*rets, 8, 'filled', 'MarkerFaceAlpha', 0.4);
scatter(100*vols, 100*mu, 60, 'r', 'filled');
text(100*vols + 0.2, 100*mu, names, 'FontSize', 8);
scatter(100*pVol, 100*pRet, 150, 'k', 'p', 'filled');
xlabel('Risk: annual volatility (%)');
ylabel('Expected return: annual (%)');
title('5000 random portfolios vs individual stocks');
legend('Random portfolios','Individual stocks','Equal-weight portfolio', ...
       'Location','southeast');