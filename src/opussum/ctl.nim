## This file contains CTL functions that can be used in the performCTL function for decoder and encoders.
## It also contains helper functions for working with decoder and encoder objects
##
## Generic CTLs can be used with both while decoder and encoder CTLs can only be used with their own respective functions.

import common

import encoder, decoder



type
  Coder = OpusDecoder | OpusEncoder

  # Since I needed some hacky functions later to work with c macros I use
  # these distincts to stop people from passing invalid strings without knowing
  EncoderCTLSetter* = distinct cint
    ## CTL c macro used to set a config value for an encoder

  DecoderCTLSetter* = distinct cint
    ## CTL c macro used to set a config value for a decoder

  EncoderCTLGetter* = distinct cint
    ## CTL c macro used to get a config value for an encoder

  DecoderCTLGetter* = distinct cint
    ## CTL c macro used to get a config value for a decoder

  GenericCTLGetter* = distinct cint
    ## CTL c macro that can be used for both encoders and decoders
  GenericCTLSetter* = distinct cint
    ## CTL c macro that can be used for both encoders and decoders

  CTLGetter = GenericCTLGetter | EncoderCTLGetter | DecoderCTLGetter
    ## Any CTL c macro that gets a value
  CTLSetter = GenericCTLSetter | EncoderCTLSetter | DecoderCTLSetter
    ## Any CTL c macro that sets a value
      
const
  # Generic CTL codes

  resetState* = 4028.cint
    ## Resets the codec state to be equivalent to a freshly initialized state
    ##
    ## This should be called when switching streams in order to prevent the back to back decoding from giving different results
    ## from one at a time decoding

  opusAuto* = -1000.cint
    ## Auto/default setting

  bitrateMax* = -1.cint
    ## Maximum bitrate
  bandwidthNarrow* = 1101.cint
    ## 4 kHz bandpass
  bandwidthMedium* = 1102.cint
    ## 6 kHz bandpass
  bandwidthWide* = 1103.cint
    ## 8 kHz bandpass
  bandwidthSuperwide* = 1104.cint
    ## 12 kHz bandpass
  bandwidthFull* = 1105.cint
    ## 20 kHz bandpass
  
  getInDTX* = 4049.GenericCTLGetter
    ## Gets the DTX state of the encoder.

  getPhaseInversionDisabled* = 4047.GenericCTLGetter
    ## Gets the encoder's configured phase inversion status.

  setPhaseInversionDisabled* = 4046.GenericCTLSetter
    ## If set to 1, disables the use of phase inversion for intensity stereo, improving the quality of mono downmixes, but slightly
    ## reducing normal stereo quality.
    ## Disabling phase inversion in the decoder does not comply with RFC 6716, although it does not cause any interoperability
    ## issue and is expected to become part of the Opus standard once RFC 6716 is updated by draft-ietf-codec-opus-update.

  getSampleRate* = 4029.GenericCTLGetter
    ## Gets the sampling rate the encoder or decoder was initialized with.
    ## This simply returns the `fs` value passed to the init function

  getBandwidth* = 4009.GenericCTLGetter
    ## Gets the encoder's configured bandpass or the decoder's last bandpass .

  getFinalRange* = 4031.GenericCTLGetter
    ## Gets the final state of the codec's entropy coder
    ##
    ## This is used for testing purposes, The encoder and decoder state should be identical after coding a payload (assuming no data corruption or software bugs)

  # Encoder CTL codes

  setComplexity* = 4010.EncoderCTLSetter
    ## Configures the encoder's computational complexity.

  getComplexity* = 4011.EncoderCTLGetter
    ## Gets the encoder's complexity configuration.

  setBitrate* = 4002.EncoderCTLSetter
    ## Configures the bitrate in the encoder.

  getBitrate* = 4003.EncoderCTLGetter
    ## Gets the encoder's bitrate configuration.

  setVbr* = 4006.EncoderCTLSetter
    ## Enables or disables variable bitrate (VBR) in the encoder.

  getVbr* = 4007.EncoderCTLGetter
    ## Determine if variable bitrate (VBR) is enabled in the encoder.

  setVbrConstraint* = 4020.EncoderCTLSetter
    ## Enables or disables constrained VBR in the encoder.

  getVbrConstraint* = 4021.EncoderCTLGetter
    ## Determine if constrained VBR is enabled in the encoder.

  setForceChannels* = 4022.EncoderCTLSetter
    ## Configures mono/stereo forcing in the encoder.

  getForceChannels* = 4023.EncoderCTLGetter
    ## Gets the encoder's forced channel configuration.

  setMaxBandwidth* = 4004.EncoderCTLSetter
    ## Configures the maximum bandpass that the encoder will select automatically.

  getMaxBandwidth* = 4005.EncoderCTLGetter
    ## Gets the encoder's configured maximum allowed bandpass.

  setBandwidth* = 4008.EncoderCTLSetter
    ## Sets the encoder's bandpass to a specific value.

  setSignal* = 4024.EncoderCTLSetter
    ## Configures the type of signal being encoded.

  getSignal* = 4025.EncoderCTLGetter
    ## Gets the encoder's configured signal type.

  setApplication* = 4000.EncoderCTLSetter
    ## Configures the encoder's intended application.

  getApplication* = 4001.EncoderCTLGetter
    ## Gets the encoder's configured application.

  getLookahead* = 4027.EncoderCTLGetter
    ## Gets the total samples of delay added by the entire codec.

  setInbandFec* = 4012.EncoderCTLSetter
    ## Configures the encoder's use of inband forward error correction (FEC).

  getInbandFec* = 4013.EncoderCTLGetter
    ## Gets encoder's configured use of inband forward error correction.

  setPacketLossPerc* = 4014.EncoderCTLSetter
    ## Configures the encoder's expected packet loss percentage.

  getPacketLossPerc* = 4015.EncoderCTLGetter
    ## Gets the encoder's configured packet loss percentage.

  setDtx* = 4016.EncoderCTLSetter
    ## Configures the encoder's use of discontinuous transmission (DTX).

  getDtx* = 4017.EncoderCTLGetter
    ## Gets encoder's configured use of discontinuous transmission.

  setLsbDepth* = 4036.EncoderCTLSetter
    ## Configures the depth of signal being encoded.

  getLsbDepth* = 4037.EncoderCTLGetter
    ## Gets the encoder's configured signal depth.

  setExpertFrameDuration* = 4040.EncoderCTLSetter
    ## Configures the encoder's use of variable duration frames.

  getExpertFrameDuration* = 4041.EncoderCTLGetter
    ## Gets the encoder's configured use of variable duration frames.

  setPredictionDisabled* = 4042.EncoderCTLSetter
    ## If set to 1, disables almost all use of prediction, making frames almost completely independent.

  getPredictionDisabled* = 4043.EncoderCTLGetter
    ## Gets the encoder's configured prediction status

  # Decoder CTL commands

  setGain* = 4034.EncoderCTLSetter
    ## Configures decoder gain adjustment.

  getGain* = 4045.EncoderCTLGetter
    ## Gets the decoder's configured gain adjustment.

  getLastPacketDuration* = 4039.EncoderCTLGetter
    ## Gets the duration (in samples) of the last packet successfully decoded or concealed.

  getPitch* = 4033.EncoderCTLGetter
    ## Gets the pitch of the last decoded frame, if available


template performCTLImpl(coder: Coder, mode, param: untyped) =
  ## The implementation of performing a ctl command.
  # get c proc name to call and check if the command being passed makes sense
  when coder is OpusEncoder:
    when mode isnot `GenericCTL mode` | `EncoderCTL mode`:
      {.error: "Only generic or encoder CTL commands allowed".}
  elif coder is OpusDecoder:
    when mode isnot `GenericCTL mode` | `DecoderCTL mode`:
      {.error: "Only generic or decoder CTL commands allowed".}
  else:
    {.error: "You have found dragons!".}
  checkRC coder.internal.performCTL(mode.cint, param)
  

proc reset*(coder: Coder) =
  ## Runs _resetState CTL command
  checkRC coder.internal.performCTL(resetState)

proc performCTL*(coder: Coder, getter: CTLGetter): cint =
  ## Runs a CTL get code and returns the value
  runnableExamples:
    import opussum
    let encoder = createEncoder(48000, 2, 960, Audio)
    doAssert encoder.performCTL(getBitrate) == 120000
  coder.performCTLImpl(getter, addr result)


proc performCTL*(coder: Coder, setter: CTLSetter, val: int32) =
  ## Runs a CTL set code using `val`
  runnableExamples:
    import opussum
    let encoder = createEncoder(48000, 2, 960, Audio)
    encoder.performCTL(setMaxBandwidth, bandwidthWide.int32)
    encoder.performCTL(
      setMaxBandwidth,
      bandwidthWide.int32
    )

  coder.performCTLImpl(setter, val.cint)

