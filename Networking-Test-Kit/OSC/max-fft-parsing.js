// OpenBCI FFT Data Parser for Max/MSP
// PROVIDED AS-IS UNDER MIT LICENSE. NO WARRANTY OF ANY KIND. USE AT YOUR OWN RISK.
// Usage:
//   [udpreceive <port>] -> (route or oscbank) -> [js max-fft-parsing.js]
//   Send list messages of the form: parseOSC <osc_address> <value>
//   Example: parseOSC /openbci/fft/ch0/bin4 1.815383
//
// Provided JS functions (send as messages to the js object):
//   parseOSC <address> <value>         // Update internal buffer for a single bin
//   getChannel <channelIndex>          // Output all bins for channel on outlet 1
//   getBandPower <ch> <startBin> <endBin> // Average power over bin range on outlet 2
//   getEEGBands <channelIndex>         // Outputs delta, theta, alpha, beta, gamma on outlet 3
//   getPeakFrequency <channelIndex>    // Outputs peak frequency (Hz) + amplitude on outlet 4
//   outputMatrix                       // Outputs entire channel arrays on outlet 5
//   setChannels <n>                    // Resize data structure (#channels)
//   setBins <n>                        // Resize number of bins
//   clear                              // Reset all stored values to 0
//   testOutlets                        // Emits a test message from every outlet
//
// Outlets:
//   0: bin_data <channel> <bin> <amplitude>
//   1: channel_data <channel> <bin> <amplitude>
//   2: band_power <channel> <startBin> <endBin> <avgPower>
//   3: eeg_bands <channel> <delta> <theta> <alpha> <beta> <gamma>
//   4: peak_freq <channel> <peakFreqHz> <amplitude>
//   5: matrix <channel> <list_of_bin_values>
//
// NOTE: Declare outlets BEFORE doing work so Max creates them.
var inlets = 1; // single inlet for all commands (var required for Max JS global)
var outlets = 6; // six data/analysis outlets (var required for Max JS global)

// Assist strings for UI clarity
setoutletassist(0, 'bin_data: ch bin value');
setoutletassist(1, 'channel_data: ch bin value');
setoutletassist(2, 'band_power: ch startBin endBin avgPower');
setoutletassist(3, 'eeg_bands: ch delta theta alpha beta gamma');
setoutletassist(4, 'peak_freq: ch peakFreqHz amplitude');
setoutletassist(5, 'matrix: ch list_of_bins');

// Global variables to store FFT data
var fftData = {};
var numChannels = 8; // Adjust based on your OpenBCI setup
var numBins = 125;
var binSize = 2; // Hz per bin (assuming 250Hz sample rate)

// Initialize data structure
function init() {
	for (var ch = 0; ch < numChannels; ch++) {
		fftData[ch] = new Array(numBins);
		for (var bin = 0; bin < numBins; bin++) {
			fftData[ch][bin] = 0;
		}
	}
	post(
		'OpenBCI FFT Parser initialized for ' +
			numChannels +
			' channels, ' +
			numBins +
			' bins\n'
	);
}

// Main function to parse incoming OSC messages
function parseOSC() {
	var oscAddress = arguments[0];
	var value = arguments[1];

	// Parse the OSC address pattern
	// Expected format: /openbci/fft/ch{channel}/bin{bin}
	// Match either /openbci/fft/chX/binY or /chX/binY (if prefix routed out earlier)
	var addressMatch = oscAddress.match(/(?:\/openbci\/fft)?\/ch(\d+)\/bin(\d+)/);

	if (addressMatch) {
		var channel = parseInt(addressMatch[1], 10);
		var bin = parseInt(addressMatch[2], 10);

		// Store the FFT value
		if (channel < numChannels && bin < numBins) {
			fftData[channel][bin] = parseFloat(value);

			// Output individual bin data
			outlet(0, 'bin_data', channel, bin, value);
		}
	}
}

// Get FFT data for a specific channel
function getChannel(channel) {
	if (channel >= 0 && channel < numChannels && fftData[channel]) {
		// Output all bins for this channel
		for (var bin = 0; bin < numBins; bin++) {
			outlet(1, channel, bin, fftData[channel][bin]);
		}
	}
}

// Get specific frequency band power
function getBandPower(channel, startBin, endBin) {
	if (channel >= 0 && channel < numChannels && fftData[channel]) {
		var bandPower = 0;
		var binCount = 0;

		for (var bin = startBin; bin <= endBin && bin < numBins; bin++) {
			bandPower += fftData[channel][bin];
			binCount++;
		}

		if (binCount > 0) {
			var avgPower = bandPower / binCount;
			outlet(2, 'band_power', channel, startBin, endBin, avgPower);
		}
	}
}

// Get common EEG frequency bands
function getEEGBands(channel) {
	if (channel >= 0 && channel < numChannels && fftData[channel]) {
		// Frequency bands (assuming 250Hz sample rate, 125 bins)
		// Each bin = 2Hz, so bin N = N * 2 Hz

		var delta = getBandAverage(channel, 0, 2); // 0-4 Hz
		var theta = getBandAverage(channel, 2, 4); // 4-8 Hz
		var alpha = getBandAverage(channel, 4, 6); // 8-12 Hz
		var beta = getBandAverage(channel, 6, 15); // 12-30 Hz
		var gamma = getBandAverage(channel, 15, 25); // 30-50 Hz

		outlet(3, 'eeg_bands', channel, delta, theta, alpha, beta, gamma);
	}
}

// Helper function to calculate average power in a bin range
function getBandAverage(channel, startBin, endBin) {
	var sum = 0;
	var count = 0;

	for (var bin = startBin; bin <= endBin && bin < numBins; bin++) {
		sum += fftData[channel][bin];
		count++;
	}

	return count > 0 ? sum / count : 0;
}

// Find peak frequency in a channel
function getPeakFrequency(channel) {
	if (channel >= 0 && channel < numChannels && fftData[channel]) {
		var maxValue = 0;
		var peakBin = 0;

		for (var bin = 1; bin < numBins; bin++) {
			// Skip DC component (bin 0)
			if (fftData[channel][bin] > maxValue) {
				maxValue = fftData[channel][bin];
				peakBin = bin;
			}
		}

		var peakFreq = peakBin * binSize;
		outlet(4, 'peak_freq', channel, peakFreq, maxValue);
	}
}

// Output all channel data as a matrix
function outputMatrix() {
	for (var ch = 0; ch < numChannels; ch++) {
		if (fftData[ch]) {
			var channelArray = [];
			for (var bin = 0; bin < numBins; bin++) {
				channelArray.push(fftData[ch][bin]);
			}
			outlet(5, 'matrix', ch, channelArray);
		}
	}
}

// Emit a test message from every outlet so user can confirm they exist
function testOutlets() {
	outlet(0, 'test', 'outlet0');
	outlet(1, 'test', 'outlet1');
	outlet(2, 'test', 'outlet2');
	outlet(3, 'test', 'outlet3');
	outlet(4, 'test', 'outlet4');
	outlet(5, 'test', 'outlet5');
	post('Emitted test messages on all 6 outlets\n');
}

// Set number of channels dynamically
function setChannels(numCh) {
	numChannels = parseInt(numCh);
	init();
	post('Set to ' + numChannels + ' channels\n');
}

// Set number of bins dynamically
function setBins(numBin) {
	numBins = parseInt(numBin);
	init();
	post('Set to ' + numBins + ' bins\n');
}

// Clear all data
function clear() {
	init();
	post('FFT data cleared\n');
}

// Initialize on load
init();
