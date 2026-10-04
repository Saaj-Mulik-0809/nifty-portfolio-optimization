%% Step 2: Download 5 years of daily adjusted close prices from Yahoo Finance
clear; clc;

tickers = ["RELIANCE.NS","TCS.NS","HDFCBANK.NS","INFY.NS","ITC.NS", ...
           "HINDUNILVR.NS","SUNPHARMA.NS","MARUTI.NS","LT.NS","TATASTEEL.NS","^NSEI"];
names   = ["RELIANCE","TCS","HDFCBANK","INFY","ITC", ...
           "HINDUNILVR","SUNPHARMA","MARUTI","LT","TATASTEEL","NIFTY50"];

opts = weboptions('UserAgent','Mozilla/5.0','Timeout',30);

prices = [];
for i = 1:numel(tickers)
    fprintf('Downloading %s ...\n', tickers(i));
    tt = fetchYahoo(tickers(i), names(i), opts);
    if isempty(prices)
        prices = tt;
    else
        prices = synchronize(prices, tt, 'intersection');  % keep only common dates
    end
    pause(1);   % be polite to the server
end

prices = rmmissing(prices);   % drop any rows with missing values
save('prices.mat','prices');  % so we never need to download again

fprintf('\nRows (days): %d | Columns (assets): %d\n', height(prices), width(prices));
fprintf('From %s to %s\n', string(prices.Time(1)), string(prices.Time(end)));
disp(head(prices,5));

%% Sanity check plot: every asset rebased to 100 at the start
figure;
plot(prices.Time, 100 * prices{:,:} ./ prices{1,:});
legend(prices.Properties.VariableNames, 'Location','northwest');
title('Growth of 100 invested 5 years ago'); ylabel('Value'); grid on;

%% Helper function (keep at the bottom of the file)
function tt = fetchYahoo(ticker, name, opts)
    sym = strrep(ticker, '^', '%5E');
    url = "https://query1.finance.yahoo.com/v8/finance/chart/" + sym + ...
          "?range=5y&interval=1d";
    data = webread(url, opts);
    r = data.chart.result;
    t = datetime(r.timestamp, 'ConvertFrom','posixtime');
    t = dateshift(t, 'start', 'day');
    adj = r.indicators.adjclose.adjclose;
    tt = timetable(t(:), adj(:), 'VariableNames', {char(name)});
end