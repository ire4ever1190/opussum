import common, pcmdata

## The encoder is used to encode raw PCM bytes into opus frames.

type
  OpusEncoderRaw* = object
    ## The C struct of OpusEncoder. It is recommended to use OpusEncoder_ procs instead since they handle memory

  OpusEncoder* = OpaqueOpusObject[OpusEncoderRaw]

{.push header: opusHeader.}
proc getEncoderSize*(channels: cint): cint {.importc: "opus_encoder_get_size".}
  ## Gets the size of an OpusEncoderRaw structure
  ## * **channels**: Number of channels. This must be 1 or 2

proc init*(st: ptr OpusEncoderRaw, fs: opusInt32, channels, application: cint): cint {.importc: "opus_encoder_init".}
  ## Initializes a previously allocated encoder state The memory pointed to by st must be at least the size returned by getEncoderSize_.
  ## This is intended for applications which use their own allocator instead of malloc
  ## * **str**: Encoder state
  ## * **fs**: Sampling rate of input signal (Hz). This must be one of 8000, 12000, 16000, 24000, or 48000
  ## * **channels**: Number of channels in input signal
  ## * **application**: Coding mode. See _OpusApplicationModes

proc encode*(st: ptr OpusEncoderRaw, data: ptr opusInt16, frameSize: cint, outData: cstring, max_data_bytes: opusInt32): opusInt32 {.importc: "opus_encode"}
  ## Encodes an opus frame
  ## * **st**: Encoder state
  ## * **data**: Input signal (interleaved if 2 channels). Length is (frame_size * channels * sizeof(opus_int16))
  ## * **frameSize**: Number of samples per channel in the input signal. This must be an Opus frame size
  ## * **outData**: Output payload. This must contain storage for at least max_data_bytes
  ## * **max_data_bytes**: Size of the allocated memory for the output payload (4000 is recommended). This may be used to impose an upper limit on the instant bitrate, but should not be used as the only bitrate control. Use setBitrate_ to control the bitrate.
  ## * **returns**: Length of the encoded bytes on success or error code on failure
proc opusCreateEncoder*(fs: opusInt32, channels, application: cint, error: ptr cint): ptr OpusEncoderRaw {.importc: "opus_encoder_create".}
  ## Allocates and initialises an encoder state
  ## * **fs**: Sampling rate of the input signal. This must be one of 8000, 12000, 16000, 24000, or 48000
  ## * **channels**: Number of channels (1 or 2) in input signal
  ## * **application**: Coding mode
  ## * **error**: Error code is put in here


proc destroy*(st: ptr OpusEncoderRaw) {.importc: "opus_encoder_destroy".}
  ## Frees an OpusEncoderRaw_ allocated by opusCreateEncoder_

{.pop.}

proc createEncoder*(sampleRate: int32, channels: range[1..2], frameSize: int, application: OpusApplicationModes): OpusEncoder =
  ## Creates an encoder. This is recommend over opusCreateEncoder_ since this has more helper procs and you don't need to manage
  ## its memory
  checkSampleRate sampleRate
  var error: cint
  result.internal = opusCreateEncoder(sampleRate.opusInt32, channels.cint, application.ord.cint, addr error)
  result.frameSize = frameSize
  result.channels = channels
  checkRC error

proc encode*(encoder: OpusEncoder, data: PCMData): OpusFrame =
  ## Encodes some PCMBytes_ into an opus frame
  assert encoder.internal != nil, "Encoder has been destroyed"
  # Allocate needed buffers
  var outData = cast[cstring](createShared(char, data.len))

  let length = encoder.internal.encode(
    cast[ptr opusInt16](data.data),
    encoder.frameSize.cint,
    outData,
    data.len.cint
  )
  checkRC length
  # Move bytes to result
  result = OpusFrame(newString length)
  for i in 0..<length:
    result.cstring[i] = outData[i]
