clr;
addpath(genpath('liblsl-Matlab'));

lib = lsl_loadlib(); version = lsl_library_version(lib)
% resolve a stream...
disp('Resolving an EEG stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); end

% create a new inlet
disp('Opening an inlet...');
inlet = lsl_inlet(result{1});

% Set the time interval for counting samples (in seconds)
timeInterval = 5; % Adjust as needed

% Initialize the sample counter and start time
sampleCount = 0;
startTime = tic;

disp('Now receiving data...');
while true
    % get data from the inlet
    [vec,ts] = inlet.pull_sample();
    % Display data (optional)
%     fprintf('%.2f\t',vec);
%     fprintf('%.5f\n',ts);

    % Increment the sample counter
    sampleCount = sampleCount + 1;
    
    % Check if the time interval has elapsed
    elapsedTime = toc(startTime);
    if elapsedTime >= timeInterval
        % Calculate the samples per second (SPS)
        samplesPerSecond = sampleCount / elapsedTime;
        
        % Display the result
        fprintf('Received %.0f samples in %.2f seconds\n', sampleCount, elapsedTime);
        fprintf('Samples per second: %.2f\n', samplesPerSecond);
        
        % Reset the sample counter and start time
        sampleCount = 0;
        startTime = tic;
    end
end