import carray

{.passC: staticExec("pkg-config --cflags opus").}
{.passL: staticExec("pkg-config --libs opus").}


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
    ## .. Note:: While these are positive, opus returns negative codes so make sure to do conversion (Or use checkRC_)
    BadArg = 1
    BufferTooSmall = 2
    InternalError = 3
    InvalidPacket = 4
    Unimplemented = 5
    InvalidState = 6
    AllocFail = 7

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

  OpusFrame* = CArray[uint8]

const
  allowedSamplingRates* = [8000.int32, 12000, 16000, 24000, 48000]
  opusHeader* = "opus/opus.h"
  maxFrameSize* {.intdefine.} = 6 * 960
  maxPacketSize* {.intdefine.} = 3 * 1276
  
template checkRC*(call: untyped) =
  ## Checks the return value of a function and throws error if < 0.
  let res = call
  if res < 0:
    when (NimMajor, NimMinor, NimPatch) >= (1, 6, 0):
      {.warning[HoleEnumConv]: off.}
    let error = OpusErrorCodes(abs(res))
    raise (ref OpusError)(msg: $error)

let
  opusVersion* {.header: opusHeader, importc: "API_VERSION".}: cint
    ##  API version for this opus headers. Can be used to check for features at compile time

proc packetSize*[T](obj: OpaqueOpusObject[T]): int {.inline.} =
  ## Returns the packet size for an encoder/decoder (frameSize * channels)
  result = obj.frameSize * obj.channels

proc `=destroy`[T: object](obj: var OpaqueOpusObject[T]) =
  mixin destroy
  if obj.internal != nil:
    destroy obj.internal
    obj.internal = nil

template checkSampleRate*(sampleRate: int32) =
  ## **Internal**: Used to check if a sample rate is a correct value(See allowedSamplingRates_)
  assert sampleRate in allowedSamplingRates, "sampling must be one of 8000, 12000, 16000, 24000, or 48000"

export carray
