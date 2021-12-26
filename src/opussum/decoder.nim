import common, pcmdata

## The decoder is used to decode opus frames into raw PCM bytes

type
  OpusDecoderRaw* = object
    ## The C struct of OpusDecoder. It is recommended to use OpusDecoder_ procs instead since they handle memory
  OpusDecoder* = OpaqueOpusObject[OpusDecoderRaw]


{.push header: opusHeader.}

proc getDecoderSize*(channels: cint): cint {.importc: "opus_decoder_get_size".}
  ## Gets the size of an OpusDecoderRaw_ structu
  ## * **channels**: Number of channels. This must be 1 or 2

proc opusCreateDecoder*(fs: opusInt32, channels: cint, error: ptr cint): ptr OpusDecoderRaw {.importc: "opus_decoder_create".}
  ## Allocates and initialises a decoder state
  ## * **fs**: Sample rate to decode at (Hz). This must be one of 8000, 12000, 16000, 24000, or 48000
  ## * **channels**: Number of channels (1 or 2) to decode
  ## * **error** Where to store error

proc destroy*(str: ptr OpusDecoderRaw) {.importc: "opus_decoder_destroy".}
  ## Frees an OpusEncoderRaw_ allocated by opusCreateDecoder_

proc decode*(st: ptr OpusDecoderRaw, data: cstring, len: opusInt32, outData: ptr opusInt16, frame_size, decodeFec: cint): cint {.importc: "opus_decode".}
  ## Decodes an opus packet
  ## * **st**: Decoder state
  ## * **data**: Opus encoded packet
  ## * **len**: Length of `data`
  ## * **outData**: Where to store PCM bytes (length is frameSize * channels)
  ## * **decodeFec**: flag (0 or 1) to request that any in-band forward error correction data be decoded. If no such data is available, the frame is decoded as if it was lost


proc performCTL*(st: ptr OpusDecoderRaw, request: cint): cint {.importc: "opus_encoder_ctl", varargs.}
  ## Performs a CTL code.
  ## Only generic or decoder codes can be run

{.pop.}

proc createDecoder*(sampleRate: int32, channels: range[1..2], frameSize: int): OpusDecoder =
  ## Creates a decoder. This is recommend over opusCreateEncoder_ since this has more helper procs and you don't need to manage
  ## its memory
  checkSampleRate sampleRate
  var error: cint
  result.internal = opusCreateDecoder(sampleRate, channels, addr error)
  result.frameSize = frameSize
  result.channels = channels

proc decode*(decoder: OpusDecoder, encoded: OpusFrame, errorCorrection: bool = false): PCMData =
  ## Decodes an opus frame
  let packetSize = decoder.packetSize
  result.data = cast[ptr UncheckedArray[opusInt16]](createShared(opusInt16, packetSize))
  let frameSize = decoder.internal.decode(
    encoded.cstring,
    encoded.cstring.len.opusInt32,
    cast[ptr opusInt16](result.data),
    cint(packetSize * 2),
    cast[cint](errorCorrection)
    )
  checkRC frameSize
  result.len = frameSize * 2 # frameSize is number of shorts (2 bytes) and we need bytes (1 byte)