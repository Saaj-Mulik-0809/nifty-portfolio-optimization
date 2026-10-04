%% Training vs test annualized returns per stock (Table 7 in the report)
% Uses the same 60/40 chronological split as backtest.m
clear; clc;
load('returns.mat');

R     = returns{:,1:10};
names = returns.Properties.VariableNames(1:10);
split = round(0.6 * height(returns));

trainRet = mean(R(1:split,:))     * 252 * 100;   % training period, annual %
testRet  = mean(R(split+1:end,:)) * 252 * 100;   % test period, annual %

disp(table(names', trainRet', testRet', testRet' - trainRet', ...
    'VariableNames', {'Stock','TrainReturn_pct','TestReturn_pct','Change_pct'}))
