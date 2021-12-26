#include "opus/opus_defines.h"
#include "opus/opus_types.h"
/*
    This file is made so that it is easier to make bindings
    to c #defines in nim
*/


int opus_reset_state = OPUS_RESET_STATE;
int opus_auto = OPUS_AUTO;
int opus_bitrate_max = OPUS_BITRATE_MAX;

int opus_bandwidth_narrowband = OPUS_BANDWIDTH_NARROWBAND;
int opus_bandwidth_mediumband = OPUS_BANDWIDTH_MEDIUMBAND;
int opus_bandwidth_wideband = OPUS_BANDWIDTH_WIDEBAND;
int opus_bandwidth_superwideband = OPUS_BANDWIDTH_SUPERWIDEBAND;
int opus_bandwidth_fullband = OPUS_BANDWIDTH_FULLBAND;

