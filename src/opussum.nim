
{.passC: staticExec("pkg-config --cflags opus libopusenc").}
{.passL: staticExec("pkg-config --libs opus libopusenc").}

{.pragma: opusHead, header: "opus/opusenc.h".}

# TODO: Break into multiple files
# TODO: Wrap rest of library

type
  OpusErrorCodes* = enum
    ## Various error codes that can be returned.
    ##
    ## .. Note:: While these are positive, opus returns negative codes so make sure to do conversion
    BadArg = 11.cint
    InternalError = 13.cint
    Unimplemented = 15.cint
    AllocFail = 17.cint
    CannotOpen = 30.cint
    TooLate = 31.cint
    InvalidPicture = 32.cint
    InvalidIcon = 33.cint
    WriteFail = 34.cint
    CloseFail = 35.cint

  OpusApplicationModes* = enum
    ## * **Voip**: Best for most VoIP/videoconference applications where listening quality and intelligibility matter most
    ## * **Audio**: Best for broadcast/high-fidelity application where the decoded audio should be as close as possible to the input
    ## * **RestrictedLowDelay**: Only use when lowest-achievable latency is what matters most. Voice-optimized modes cannot be used
    Voip = 2048.cint
    Audio = 2049.cint
    RestrictedLowDelay = 2051.cint

  OpusEncoderRaw* = object
    ## The C struct of OpusEncoder. It is recommended to use OpusEncoder_ procs instead since they handle memory

  OpaqueObject*[T: object] = object
    internal*: ptr T
    
  OpusEncoder* = OpaqueObject[OpusEncoderRaw]

  OpusError* = object of CatchableError

  opusInt* = cint
  opusInt64* = clonglong
  opusInt8* = cschar

  opusUInt* = cuint
  opusUint64* = culonglong
  opusUInt8* = uint8

  opusInt16* = cshort
  opusInt32* = cint
  

template checkRC*(call: untyped) =
  ## Checks the return value of a function and throws error if < 0.
  let res = call
  if res < 0:
    let error = OpusErrorCodes(abs(res))
    raise (ref OpusError)(msg: $error)
    
let
  opusVersion* {.opusHead, importc: "API_VERSION".}: cint
    ##  API version for this opus headers. Can be used to check for features at compile time  

const allowedSamplingRates = [8000.int32, 12000, 16000, 24000, 48000]

# TODO, split into different files
  
#
# Encoder
#
{.push header: "opus/opus.h".}
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


  
proc encode*(st: ptr OpusEncoderRaw, pcm: ptr opusInt16, frameSize: cint, data: cstring, max_data_bytes: opusInt32): opusInt32 {.importc: "opus_encode"}
  ## Encodes an opus frame
  ## * **st**: Encoder state
  ## * **pcm**: Input signal (interleaved if 2 channels). Length is (frame_size * channels * sizeof(opus_int16))
  ## * **data**: Output payload. This must contain storage for at least max_data_bytes
  ## * **max_data_bytes**: Size of the allocated memory for the output payload. This may be used to impose an upper limit on the instant bitrate, but should not be used as the only bitrate control. Use setBitrate_ to control the bitrate
  ## * **returns**: Length of the encoded bytes on success or error code on failure
proc opusCreateEncoder*(fs: opusInt32, channels, application: cint, error: ptr cint): ptr OpusEncoderRaw {.importc: "opus_encoder_create".}
  ## Allocates and initialises an encoder state
  ## * **fs**: Sampling rate of the input signal. This must be one of 8000, 12000, 16000, 24000, or 48000
  ## * **channels**: Number of channels (1 or 2) in input signal
  ## * **application**: Coding mode
  ## * **error**: Error code is put in here

proc createEncoder*(fs: int32, channels: range[1..2], application: OpusApplicationModes): OpusEncoder =
  ## Creates an encoder (this does not need to be destroyed manually)
  assert fs in allowedSamplingRates, "sampling must be one of 8000, 12000, 16000, 24000, or 48000"
  var error: cint
  result.internal = opusCreateEncoder(fs.opusInt32, channels.cint, application.ord.cint, addr error)
  checkRC error

proc destroy*(st: ptr OpusEncoderRaw) {.importc: "opus_encoder_destroy".}
  ## Frees an OpusEncoderRaw_ allocated by encoderCreate_

{.pop.}

proc `=destroy`*[T](obj: var OpaqueObject[T]) =
  ## Cleans up an OpaqueObject_ by destroying the internal pointer
  if obj != nil and obj.internal != nil:
    destroy obj.internal
    obj.internal = nil
    obj = nil
