////////////////////////////////////////////////////////////////////////////////////////////////
//                                   EMG Values Data Class                                    //
//                              Richard Waltman - February 2023                               //
//   Make this class full of arrays rather than instances of single class full of values.     //
//  This supports having custom settings that can be easily modified on a per-channel basis.  //
////////////////////////////////////////////////////////////////////////////////////////////////

class EmgSettingsValues {

    //These values can be changed via dropdowns
    public EmgSmoothing[] smoothing;
    public EmgUVLimit[] uvLimit;
    public EmgCreepIncreasing[] creepIncreasing;
    public EmgCreepDecreasing[] creepDecreasing;
    public EmgMinimumDeltaUV[] minimumDeltaUV;
    public EmgLowerThresholdMinimum[] lowerThresholdMinimum;
    //Normalized output which is passed to Networking
    float[] outputNormalized;
    //These values change during calculations
    float[] upperThreshold;
    float[] lowerThreshold;
    float[] averageuV;

    private int channelCount;

    EmgSettingsValues() {

        channelCount = currentBoard.getNumEXGChannels();

        smoothing = new EmgSmoothing[channelCount];
        uvLimit = new EmgUVLimit[channelCount];
        creepIncreasing = new EmgCreepIncreasing[channelCount];
        creepDecreasing = new EmgCreepDecreasing[channelCount];
        minimumDeltaUV = new EmgMinimumDeltaUV[channelCount];
        lowerThresholdMinimum = new EmgLowerThresholdMinimum[channelCount];

        outputNormalized = new float[channelCount];
        upperThreshold = new float[channelCount];
        lowerThreshold = new float[channelCount];
        averageuV = new float[channelCount];

        Arrays.fill(smoothing, EmgSmoothing.ONE_SECOND);
        Arrays.fill(uvLimit, EmgUVLimit.TWO_HUNDRED_UV);
        Arrays.fill(creepIncreasing, EmgCreepIncreasing.POINT_9);
        Arrays.fill(creepDecreasing, EmgCreepDecreasing.POINT_99999);
        Arrays.fill(minimumDeltaUV, EmgMinimumDeltaUV.TEN_UV);
        Arrays.fill(lowerThresholdMinimum, EmgLowerThresholdMinimum.SIX_UV);
        Arrays.fill(outputNormalized, 0);
        Arrays.fill(upperThreshold, 25);
        Arrays.fill(lowerThreshold, 0);
        Arrays.fill(averageuV, 0.0);
    }

    //Pass filtered data into this method
    public void process(float[][] data_forDisplay_uV) {
        //looping over channels and analyzing input data
        for (int i = 0; i < channelCount; i++) {
            float averagePeriod = currentBoard.getSampleRate() * smoothing[i].getValue();
            int _uvLimit = uvLimit[i].getValue();
            float creepSpeedIncreasing = creepIncreasing[i].getValue();
            float creepSpeedDecreasing = creepDecreasing[i].getValue();
            int _minimumDeltaUV = minimumDeltaUV[i].getValue();
            int _lowerThresholdMininum = lowerThresholdMinimum[i].getValue();
            
            //Calculate average
            averageuV[i] = 0.0;
            for (int j = data_forDisplay_uV[i].length - int(averagePeriod); j < data_forDisplay_uV[i].length; j++) {
                if (abs(data_forDisplay_uV[i][j]) <= _uvLimit) { //prevent BIG spikes from effecting the average
                    averageuV[i] += abs(data_forDisplay_uV[i][j]);  //add value to average ... we will soon divide by # of packets
                } else {
                    averageuV[i] += _uvLimit; //if it's greater than the limit, just add the limit
                }
            }
            averageuV[i] = averageuV[i] / averagePeriod; //finishing the average

            if (averageuV[i] >= upperThreshold[i] && averageuV[i] <= _uvLimit) { //
                upperThreshold[i] = averageuV[i];
            }
            if (averageuV[i] <= lowerThreshold[i]) {
                lowerThreshold[i] = averageuV[i];
            }
            if (upperThreshold[i] >= (averageuV[i] + _minimumDeltaUV)) {  //minRange = 15
                upperThreshold[i] *= creepSpeedIncreasing; //adjustmentSpeed
            }
            if (lowerThreshold[i] <= 1){
                lowerThreshold[i] = 1.0;
            }
            if (lowerThreshold[i] <= averageuV[i]) {
                lowerThreshold[i] *= (1 / creepSpeedDecreasing); //adjustmentSpeed
            }
            if (lowerThreshold[i] < _lowerThresholdMininum) {
                lowerThreshold[i] = _lowerThresholdMininum;
            }
            if (upperThreshold[i] <= (lowerThreshold[i] + _minimumDeltaUV)){
                upperThreshold[i] = lowerThreshold[i] + _minimumDeltaUV;
            }

            outputNormalized[i] = map(averageuV[i], lowerThreshold[i], upperThreshold[i], 0, 1);
            if(outputNormalized[i] < 0){
                outputNormalized[i] = 0; //always make sure this value is >= 0
            }
        }
    }
}