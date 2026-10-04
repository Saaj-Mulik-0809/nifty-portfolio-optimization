%% Step 6: Value at Risk
clear; clc;
load('returns.mat');
load('opt_weights.mat');

R  = returns{:,1:10};
P  = [R*wEq, R*wMin, R*wMax, returns{:,11}];     % daily returns of 4 portfolios
labels = {'Equal weight','Min variance','Max Sharpe','NIFTY50'};
N = size(P,1);
invest = 1000000;                                % assume Rs 10 lakh invested

z95 = 1.645;  z99 = 2.326;                       % normal-curve constants

fprintf('1-day risk, as %% of portfolio (and Rs on Rs 10 lakh for 95%% hist VaR)\n\n');
fprintf('%-14s %9s %9s %9s %9s %9s %12s\n', 'Portfolio', ...
        'HistVaR95','ParamVaR95','CVaR95','HistVaR99','CVaR99','Rs_at_95');
for c = 1:4
    x = P(:,c);
    s = sort(x);                                  % worst day first
    k95 = floor(0.05*N);  k99 = floor(0.01*N);

    hVaR95 = -s(k95);                             % 5th-percentile loss
    cVaR95 = -mean(s(1:k95));                     % average of the worst 5% of days
    hVaR99 = -s(k99);
    cVaR99 = -mean(s(1:k99));
    pVaR95 = -(mean(x) - z95*std(x));             % bell-curve version

    fprintf('%-14s %8.2f%% %8.2f%% %8.2f%% %8.2f%% %8.2f%% %12.0f\n', labels{c}, ...
        100*hVaR95, 100*pVaR95, 100*cVaR95, 100*hVaR99, 100*cVaR99, invest*hVaR95);
end

%% Histogram of Equal-weight returns with VaR line
x = P(:,1);  s = sort(x);  v95 = -s(floor(0.05*N));
figure; hold on; grid on;
histogram(100*x, 50, 'FaceColor',[0.3 0.6 0.9]);
xline(-100*v95, 'r', 'LineWidth', 2);
xlabel('Daily return (%)'); ylabel('Number of days');
title('Equal-weight portfolio: daily returns and 95% VaR (red line)');