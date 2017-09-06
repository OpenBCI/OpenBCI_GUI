clear
clc
fs = [125 200 250 1000 1600];
b = cell(6, 1);
a = cell(6, 1);

c = cell(6, 1);
% results are stored in c, c{1} is the result of filter1, c{2} is the result of filter2, ...
% each page of c{i} consists of 10 rows data, each two rows are [b,a] for fs(1:5)
% e.g. in c{1}, [row 1, row 2] = butter(2,[59.0 61.0]/(fs(1) / 2.0)
%               [row 3, row 4] = butter(2,[59.0 61.0]/(fs(2) / 2.0) ...

for i = 1:length(fs)
    [b{1}(i, :), a{1}(i, :)] = butter(2,[59.0 61.0]/(fs(i) / 2.0), 'stop'); % notch 60Hz
    [b{2}(i, :), a{2}(i, :)] = butter(2,[49.0 51.0]/(fs(i) / 2.0), 'stop'); % notch 50Hz
    [b{3}(i, :), a{3}(i, :)] = butter(2,[1.0 50.0]/(fs(i) / 2.0));  % bandpass 1-50Hz
    [b{4}(i, :), a{4}(i, :)] = butter(2,[7.0 13.0]/(fs(i) / 2.0));  % bandpass 7-13Hz
    [b{5}(i, :), a{5}(i, :)] = butter(2,[15.0 50.0]/(fs(i) / 2.0)); % bandpass 15-50Hz
    [b{6}(i, :), a{6}(i, :)] = butter(2,[5.0 50.0]/(fs(i) / 2.0));  % bandpass 5-50Hz
end

for k = 1:length(c)
    for i = 1:length(fs)
        c{k}(2*i - 1, :) = b{k}(i, :);
        c{k}(2*i, :) = a{k}(i, :);
    end
end
