
// creates an DataPacket with interpolated values.
// the bias is a float between 0 and 1. It's the weight between the two packets.
// a bias of 0 will return packet "first"
// a bias of 1 will return packet "second"
// a bias of 0.5 will return the average of the two.
// This is exactly the behavior of a lerp() function
DataPacket CreateInterpolatedPacket(DataPacket first, DataPacket second, float bias) {
    int nValues = first.values.length;
    int nAuxValues = first.auxValues.length;

    DataPacket interpolated = new DataPacket(nValues, nAuxValues);
    first.copyTo(interpolated);
    
    interpolated.interpolated = true;

    for (int i=0; i < nValues; i++) {
        interpolated.values[i] = lerpInt(first.values[i], second.values[i], bias);
    }

    for (int i=0; i < nAuxValues; i++) {
        interpolated.auxValues[i] = lerpInt(first.auxValues[i], second.auxValues[i], bias);
    }

    interpolated.sampleIndex = lerpInt(first.sampleIndex, second.sampleIndex, bias);
    interpolated.timeStamp = lerpInt(first.timeStamp, second.timeStamp, bias);

    return interpolated;
}

class DataPacket {
    private final int rawAdsSize = 3;
    private final int rawAuxSize = 2;

    int sampleIndex;
    long timeStamp;
    int[] values;
    int[] auxValues;
    byte[][] rawValues;
    byte[][] rawAuxValues;
    boolean interpolated;

    //constructor, give it "nValues", which should match the number of values in the
    //data payload in each data packet from the Arduino.  This is likely to be at least
    //the number of EEG channels in the OpenBCI system (ie, 8 channels if a single OpenBCI
    //board) plus whatever auxiliary data the Arduino is sending.
    DataPacket(int nValues, int nAuxValues) {
        values = new int[nValues];
        auxValues = new int[nAuxValues];
        rawValues = new byte[nValues][rawAdsSize];
        rawAuxValues = new byte[nAuxValues][rawAdsSize];
        interpolated = false; // default
    }

    int copyTo(DataPacket target) { return copyTo(target, 0, 0); }
    private int copyTo(DataPacket target, int target_startInd_values, int target_startInd_aux) {
        target.sampleIndex = sampleIndex;
        target.timeStamp = timeStamp;
        return copyValuesAndAuxTo(target, target_startInd_values, target_startInd_aux);
    }
    int copyValuesAndAuxTo(DataPacket target, int target_startInd_values, int target_startInd_aux) {
        int nvalues = values.length;
        for (int i=0; i < nvalues; i++) {
            target.values[target_startInd_values + i] = values[i];
            target.rawValues[target_startInd_values + i] = rawValues[i];
        }
        nvalues = auxValues.length;
        for (int i=0; i < nvalues; i++) {
            target.auxValues[target_startInd_aux + i] = auxValues[i];
            target.rawAuxValues[target_startInd_aux + i] = rawAuxValues[i];
        }
        return 0;
    }
};