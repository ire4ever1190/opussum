# TODO: Wrap rest of library

type
  OpusErrorCodes* = enum
    ## Various error codes that can be returned.
    ## * **BadArg**: One or more invalid/out of range arguments
    ## * **BufferTooSmall**: Not enough bytes allocated in the buffer.
    ## * **InternalError**: An internal error was detected.
    ## * **InvalidPacket**: The compressed data passed is corrupted.
    ## * **Unimplemented**: Invalid/unsupported request number.
    ## * **InvalidState**: An encoder or decoder structure is invalid or already freed.
    ## * **AllocFail**: Memory allocation has failed
    ##
    ## .. Note:: These can be checked using checkRC_
    AllocFail = -7
    InvalidState = -6
    Unimplemented = -5
    InvalidPacket = -4
    InternalError = -3
    BufferTooSmall = -2
    BadArg = -1

  OpusApplicationModes* = enum
    ## * **Voip**: Best for most VoIP/videoconference applications where listening quality and intelligibility matter most
    ## * **Audio**: Best for broadcast/high-fidelity application where the decoded audio should be as close as possible to the input
    ## * **RestrictedLowDelay**: Only use when lowest-achievable latency is what matters most. Voice-optimized modes cannot be used
    Voip = 2048.cint
    Audio = 2049.cint
    RestrictedLowDelay = 2051.cint


  OpaqueOpusObject*[T: object] = object
    internal*: ptr T
    frameSize*: int
    channels*: int

  OpusError* = object of CatchableError

  opusInt* = cint
  opusInt64* = clonglong
  opusInt8* = cschar

  opusUInt* = cuint
  opusUint64* = culonglong
  opusUInt8* = uint8

  opusInt16* = cshort
  opusInt32* = cint

  OpusFrame* = seq[uint8]

const
  allowedSamplingRates* = [8000.int32, 12000, 16000, 24000, 48000]
  maxFrameSize* {.intdefine.} = 6 * 960
  maxPacketSize* {.intdefine.} = 3 * 1276
  opusLib* = "libopus.(so|dll)(|.0)"
  
template checkRC*(call: untyped) =
  ## Checks the return value of a function and throws error if < 0.
  let res = call
  if res < 0:
    when (NimMajor, NimMinor, NimPatch) >= (1, 6, 0):
      {.warning[HoleEnumConv]: off.}
    let error = OpusErrorCodes(res)
    raise (ref OpusError)(msg: $error)


proc packetSize*[T](obj: OpaqueOpusObject[T]): int {.inline.} =
  ## Returns the packet size for an encoder/decoder (frameSize * channels).
  ## This can be used to figure out how much needs to be read from a stream for an encoder
  result = obj.frameSize * obj.channels

proc opusVersionString*(): cstring {.cdecl, dynlib: opusLib, importc: "opus_get_version_string".} =
  ## Gets the libopus version string.
  ##
  ## Applications may look for the substring "-fixed" in the version string to determine whether they have a fixed-point or floating-point build at runtime.

proc `=destroy`[T: object](obj: var OpaqueOpusObject[T]) =
  mixin destroy
  if obj.internal != nil:
    destroy obj.internal
    obj.internal = nil

template checkSampleRate*(sampleRate: int32) =
  ## **Internal**: Used to check if a sample rate is a correct value(See allowedSamplingRates_)
  assert sampleRate in allowedSamplingRates, "sampling must be one of 8000, 12000, 16000, 24000, or 48000"

