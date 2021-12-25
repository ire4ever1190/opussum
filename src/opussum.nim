{.passC: staticExec("pkg-config --cflags opus").}
{.passL: staticExec("pkg-config --libs opus").}

{.pragma: opusHead, header: "opus/opusenc.h".}

# TODO: Break into multiple files
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

  OpusEncoderRaw* = object
    ## The C struct of OpusEncoder. It is recommended to use OpusEncoder_ procs instead since they handle memory
  OpusDecoderRaw* = object
    ## The C struct of OpusDecoder. It is recommended to use OpusDecoder_ procs instead since they handle memory

  OpaqueOpusObject*[T: object] = object
    internal*: ptr T
    frameSize*: int
    channels*: int

  PCMBytes* = object
    len*: int
    data*: ptr UncheckedArray[opusInt16]
  
  OpusEncoder* = OpaqueOpusObject[OpusEncoderRaw]
  OpusDecoder* = OpaqueOpusObject[OpusDecoderRaw]

  OpusError* = object of CatchableError

  opusInt* = cint
  opusInt64* = clonglong
  opusInt8* = cschar

  opusUInt* = cuint
  opusUint64* = culonglong
  opusUInt8* = uint8

  opusInt16* = cshort
  opusInt32* = cint

  OpusFrame* = distinct cstring


template checkRC*(call: untyped) =
  ## Checks the return value of a function and throws error if < 0.
  let res = call
  if res < 0:
    when (NimMajor, NimMinor, NimPatch) >= (1, 6, 0):
      {.warning[HoleEnumConv]: off.}
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
  ## Frees an OpusEncoderRaw_ allocated by encoderCreate_

#
# Decoder
#

proc getDecoderSize*(channels: cint): cint {.importc: "opus_decoder_get_size".}
  ## Gets the size of an OpusDecoderRaw_ structu
  ## * **channels**: Number of channels. This must be 1 or 2

proc opusCreateDecoder*(fs: opusInt32, channels: cint, error: ptr cint): ptr OpusDecoderRaw {.importc: "opus_decoder_create".}
  
proc destroy*(str: ptr OpusDecoderRaw) {.importc: "opus_decoder_destroy".}

proc decode*(st: ptr OpusDecoderRaw, data: cstring, len: opusInt32, outData: ptr opusInt16, frame_size, decode_fec: cint): cint {.importc: "opus_decode".}

{.pop.}

template makeDestructor(kind: untyped) =
  proc `=destroy`*(obj: var kind) =
    ## Cleans up an OpaqueObject_ by destroying the internal pointer
    if obj.internal != nil:
      destroy obj.internal
      obj.internal = nil

# Generic destructors don't work for some reason so I must manually define
makeDestructor(OpusDecoder)
makeDestructor(OpusEncoder)

proc `=destroy`*(pcm: var PCMBytes) =
  if pcm.data != nil:
    freeShared pcm.data
    pcm.data = nil

template checkSampleRate(sampleRate: int32) =
  assert sampleRate in allowedSamplingRates, "sampling must be one of 8000, 12000, 16000, 24000, or 48000"

proc createEncoder*(sampleRate: int32, channels: range[1..2], frameSize: int, application: OpusApplicationModes): OpusEncoder =
  ## Creates an encoder (this does not need to be destroyed manually)
  checkSampleRate sampleRate
  var error: cint
  result.internal = opusCreateEncoder(sampleRate.opusInt32, channels.cint, application.ord.cint, addr error)
  result.frameSize = frameSize
  result.channels = channels
  checkRC error

proc createDecoder*(sampleRate: int32, channels: range[1..2], frameSize: int): OpusDecoder =
  checkSampleRate sampleRate
  var error: cint
  result.internal = opusCreateDecoder(sampleRate, channels, addr error)
  result.frameSize = frameSize
  result.channels = channels

#[
     {
      int i;
      unsigned char pcm_bytes[MAX_FRAME_SIZE*CHANNELS*2];
      int frame_size;

      /* Read a 16 bits/sample audio frame. */
      fread(pcm_bytes, sizeof(short)*CHANNELS, FRAME_SIZE, fin);
      if (feof(fin))
         break;
      /* Convert from little-endian ordering. */
      for (i=0;i<CHANNELS*FRAME_SIZE;i++)
         in[i]=pcm_bytes[2*i+1]<<8|pcm_bytes[2*i];
]#

proc packetSize*[T](obj: OpaqueOpusObject[T]): int {.inline.} =
  result = obj.frameSize * obj.channels

proc toPCMBytes(data: sink string, frameSize, channels: int): PCMBytes =
  ## Converts a string to pcm bytes
  let size = frameSize * channels * 2
  echo size
  result.len = size
  result.data = cast[ptr UnCheckedArray[opusInt16]](createShared(opusInt16, size))
  # Convert to little endian int16 
  for i in 0..<(channels * frameSize):
    result.data[i] = cast[opusInt16]((data[2 * i + 1].ord shl 8) or data[2 * i].ord)

proc toPCMBytes*[T](data: sink string, opus: OpaqueOpusObject[T]): PCMBytes =
  ## Like the other `toPCMBytes` except it uses the settings from an OpusEncoder_ or OpusDecoder_
  result = data.toPCMBytes(opus.frameSize, opus.channels)
    
proc encode*(encoder: OpusEncoder, data: PCMBytes, size: int): OpusFrame =
  ## Encodes an opus frame
  # runnableExamples:
    # import std/streams
    # let
      # rawData = newFileStream("tests/test.raw", fmRead)
      # encoder = createEncoder(48000, 2, 960, Voip)
      # pcmBytes = rawData.readStr(1920 * 2).toPcmBytes(encoder)
    # let encoded = encoder.encode(pcmBytes, 1920)
     # 
  assert encoder.internal != nil, "Encoder has been destroyed"
  # Allocate needed buffers
  var outData = cast[cstring](createShared(char, size))
  
  let length = encoder.internal.encode(
    cast[ptr opusInt16](data.data),
    encoder.frameSize.cint,
    outData,
    size.cint
  )
  checkRC length
  
  # Move bytes to result
  # TODO: benchmark if it would be faster to do setLen and then move cstring to result
  result = OpusFrame(newString length)
  for i in 0..<length:
    result.cstring[i] = outData[i]

proc decode*(decoder: OpusDecoder, encoded: OpusFrame, errorCorrection: bool = false): PCMBytes =
  ## Decodes an opus frame
  let packetSize = decoder.packetSize
  result.data = cast[ptr UncheckedArray[opusInt16]](createShared(opusInt16, packetSize))
  let length = decoder.internal.decode(
    encoded.cstring, 
    encoded.cstring.len.opusInt32,
    cast[ptr opusInt16](result.data),
    cint(packetSize * 2),
    cast[cint](errorCorrection)
    )
  checkRC length
  result.len = length
  
  
proc destroy*[T](obj: OpaqueOpusObject[T]) {.inline.} =
  ## Calls the `destroy` proc that is relevant for the internal pointer
  destroy obj.internal
  obj.internal = nil
