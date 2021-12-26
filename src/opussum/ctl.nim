## This file contains CTL functions that can be used in the performCTL function for decoder and encoders.
## It also contains helper functions for working with decoder and encoder objects
##
## Generic CTLs can be used with both while decoder and encoder CTLs can only be used with their own respective functions
import common

import encoder, decoder
import os

type
  Coder = OpusDecoder | OpusEncoder

  # Since I needed some hacky functions later to work with c macros I use
  # these distincts to stop people from using the wrong c macro
  EncoderCTLSetter* = distinct string
    ## CTL c macro used to set a config value for an encoder

  DecoderCTLSetter* = distinct string
    ## CTL c macro used to set a config value for a decoder

  EncoderCTLGetter* = distinct string
    ## CTL c macro used to get a config value for an encoder

  DecoderCTLGetter* = distinct string
    ## CTL c macro used to get a config value for a decoder

  GenericCTLGetter* = distinct string
    ## CTL c macro that can be used for both encoders and decoders
  GenericCTLSetter* = distinct string
    ## CTL c macro that can be used for both encoders and decoders

  CTLGetter = GenericCTLGetter | EncoderCTLGetter | DecoderCTLGetter
  CTLSetter = GenericCTLSetter | EncoderCTLSetter | DecoderCTLSetter

{.push header: currentSourcePath().parentDir() / "concrete_defines.h".}
let
  resetState* {.importc: "opus_reset_state".}: cint
    ## Resets the codec state to be equivalent to a freshly initialized state
    ##
    ## This should be called when switching streams in order to prevent the back to back decoding from giving different results
    ## from one at a time decoding
  opusAuto* {.importc: "opus_auto".}: cint
    ## Auto/default setting
  bitrateMax* {.importc: "opus_bitrate_max"}: cint
    ## Maximum bitrate
  bandwidthNarrow*    {.importc: "opus_bandwidth_narrowband".}: cint
    ## 4 kHz bandpass
  bandwidthMedium*    {.importc: "opus_bandwidth_mediumband".}: cint
    ## 6 kHz bandpass
  bandwidthWide*      {.importc: "opus_bandwidth_wideband".}: cint
    ## 8 kHz bandpass
  bandwidthSuperwide* {.importc: "opus_bandwidth_superwideband".}: cint
    ## 12 kHz bandpass
  bandwidthFull*      {.importc: "opus_bandwitdh_fullband".}: cint
    ## 20 kHz bandpass

{.pop.}

const
  # Generic CTL codes

  getInDTX* = "OPUS_GET_IN_DTX".GenericCTLGetter
    ## Gets the DTX state of the encoder.

  getPhaseInversionDisabled* = "OPUS_GET_PHASE_INVERSION_DISABLED".GenericCTLGetter
    ## Gets the encoder's configured phase inversion status.

  setPhaseInversionDisabled* = "OPUS_SET_PHASE_INVERSION_DISABLED".GenericCTLSetter
    ## If set to 1, disables the use of phase inversion for intensity stereo, improving the quality of mono downmixes, but slightly
    ## reducing normal stereo quality.
    ## Disabling phase inversion in the decoder does not comply with RFC 6716, although it does not cause any interoperability
    ## issue and is expected to become part of the Opus standard once RFC 6716 is updated by draft-ietf-codec-opus-update.

  getSampleRate* = "OPUS_GET_SAMPLE_RATE".GenericCTLGetter
    ## Gets the sampling rate the encoder or decoder was initialized with.
    ## This simply returns the `fs` value passed to the init function

  getBandwidth* = "OPUS_GET_BANDWIDTH".GenericCTLGetter
    ## Gets the encoder's configured bandpass or the decoder's last bandpass .

  getFinalRange* = "OPUS_GET_FINAL_RANGE".GenericCTLGetter
    ## Gets the final state of the codec's entropy coder
    ##
    ## This is used for testing purposes, The encoder and decoder state should be identical after coding a payload (assuming no data corruption or software bugs)

  # Encoder CTL codes

  setComplexity* = "OPUS_SET_COMPLEXITY".EncoderCTLSetter
    ## Configures the encoder's computational complexity.

  getComplexity* = "OPUS_GET_COMPLEXITY".EncoderCTLGetter
    ## Gets the encoder's complexity configuration.

  setBitrate* = "OPUS_SET_BITRATE".EncoderCTLSetter
    ## Configures the bitrate in the encoder.

  getBitrate* = "OPUS_GET_BITRATE".EncoderCTLGetter
    ## Gets the encoder's bitrate configuration.

  setVbr* = "OPUS_SET_VBR".EncoderCTLSetter
    ## Enables or disables variable bitrate (VBR) in the encoder.

  getVbr* = "OPUS_GET_VBR".EncoderCTLGetter
    ## Determine if variable bitrate (VBR) is enabled in the encoder.

  setVbrConstraint* = "OPUS_SET_VBR_CONSTRAINT".EncoderCTLSetter
    ## Enables or disables constrained VBR in the encoder.

  getVbrConstraint* = "OPUS_GET_VBR_CONSTRAINT".EncoderCTLGetter
    ## Determine if constrained VBR is enabled in the encoder.

  setForceChannels* = "OPUS_SET_FORCE_CHANNELS".EncoderCTLSetter
    ## Configures mono/stereo forcing in the encoder.

  getForceChannels* = "OPUS_GET_FORCE_CHANNELS".EncoderCTLGetter
    ## Gets the encoder's forced channel configuration.

  setMaxBandwidth* = "OPUS_SET_MAX_BANDWIDTH".EncoderCTLSetter
    ## Configures the maximum bandpass that the encoder will select automatically.

  getMaxBandwidth* = "OPUS_GET_MAX_BANDWIDTH".EncoderCTLGetter
    ## Gets the encoder's configured maximum allowed bandpass.

  setBandwidth* = "OPUS_SET_BANDWIDTH".EncoderCTLSetter
    ## Sets the encoder's bandpass to a specific value.

  setSignal* = "OPUS_SET_SIGNAL".EncoderCTLSetter
    ## Configures the type of signal being encoded.

  getSignal* = "OPUS_GET_SIGNAL".EncoderCTLGetter
    ## Gets the encoder's configured signal type.

  setApplication* = "OPUS_SET_APPLICATION".EncoderCTLSetter
    ## Configures the encoder's intended application.

  getApplication* = "OPUS_GET_APPLICATION".EncoderCTLGetter
    ## Gets the encoder's configured application.

  getLookahead* = "OPUS_GET_LOOKAHEAD".EncoderCTLGetter
    ## Gets the total samples of delay added by the entire codec.

  setInbandFec* = "OPUS_SET_INBAND_FEC".EncoderCTLSetter
    ## Configures the encoder's use of inband forward error correction (FEC).

  getInbandFec* = "OPUS_GET_INBAND_FEC".EncoderCTLGetter
    ## Gets encoder's configured use of inband forward error correction.

  setPacketLossPerc* = "OPUS_SET_PACKET_LOSS_PERC".EncoderCTLSetter
    ## Configures the encoder's expected packet loss percentage.

  getPacketLossPerc* = "OPUS_GET_PACKET_LOSS_PERC".EncoderCTLGetter
    ## Gets the encoder's configured packet loss percentage.

  setDtx* = "OPUS_SET_DTX".EncoderCTLSetter
    ## Configures the encoder's use of discontinuous transmission (DTX).

  getDtx* = "OPUS_GET_DTX".EncoderCTLGetter
    ## Gets encoder's configured use of discontinuous transmission.

  setLsbDepth* = "OPUS_SET_LSB_DEPTH".EncoderCTLSetter
    ## Configures the depth of signal being encoded.

  getLsbDepth* = "OPUS_GET_LSB_DEPTH".EncoderCTLGetter
    ## Gets the encoder's configured signal depth.

  setExpertFrameDuration* = "OPUS_SET_EXPERT_FRAME_DURATION".EncoderCTLSetter
    ## Configures the encoder's use of variable duration frames.

  getExpertFrameDuration* = "OPUS_GET_EXPERT_FRAME_DURATION".EncoderCTLGetter
    ## Gets the encoder's configured use of variable duration frames.

  setPredictionDisabled* = "OPUS_SET_PREDICTION_DISABLED".EncoderCTLSetter
    ## If set to 1, disables almost all use of prediction, making frames almost completely independent.

  getPredictionDisabled* = "OPUS_GET_PREDICTION_DISABLED".EncoderCTLGetter
    ## Gets the encoder's configured prediction status

  # Decoder CTL commands

  setGain* = "OPUS_SET_GAIN".EncoderCTLSetter
    ## Configures decoder gain adjustment.

  getGain* = "OPUS_GET_GAIN".EncoderCTLGetter
    ## Gets the decoder's configured gain adjustment.

  getLastPacketDuration* = "OPUS_GET_LAST_PACKET_DURATION".EncoderCTLGetter
    ## Gets the duration (in samples) of the last packet successfully decoded or concealed.

  getPitch* = "OPUS_GET_PITCH".EncoderCTLGetter
    ## Gets the pitch of the last decoded frame, if available


template performCTLImpl(mode, param: untyped) =
  ## The implementation of performing a ctl command.
  # get c proc name to call and check if the command being passed makes sense
  when coder is OpusEncoder:
    const ctlProc = "opus_encoder_ctl"
    when mode isnot `GenericCTL mode` | `EncoderCTL mode`:
      {.error: "Only generic or encoder CTL commands allowed".}
  elif coder is OpusDecoder:
    const ctlProc = "opus_decoder_ctl"
    when mode isnot `GenericCTL mode` | `DecoderCTL mode`:
      {.error: "Only generic or decoder CTL commands allowed".}
  else:
    {.error: "You have found dragons!".}
  # Emit c code to call the proc using the c macros that opus defines
  var rc: cint
  {.emit: [rc, " = ",ctlProc, "(", coder.internal, ",", mode.string, "(", param, "));"].}
  checkRC rc

proc reset*(coder: Coder) =
  ## Runs _resetState CTL command
  checkRC coder.internal.performCTL(resetState)

proc performCTLGet*(coder: Coder, getter: static[CTLGetter]): cint =
  ## Runs a CTL get code and returns the value
  runnableExamples:
    let encoder = createEncoder(48000, 2, 960, Audio)
    doAssert encoder.performCTLGet(getBitrate) == 120000
  performCTLImpl(getter, result.addr)


proc performCTLSet*(coder: Coder, setter: static[CTLSetter], val: uint32) =
  ## Runs a CTL set code
  runnableExamples:
    let encoder = createEncoder(48000, 2, 960, Audio)
    encoder.performCTLSet(setBitrate, 14000)

  performCTLImpl(setter, val.cint)
