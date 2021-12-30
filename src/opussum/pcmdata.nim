import common
import lenientops

type
  PCMData* = CArray[opusInt16]

# TODO: See if this works with single channel data

proc toPCMData*(data: sink string, frameSize, channels: int): PCMData =
  ## Converts a string to pcm data.
  assert data.len <= frameSize * channels * 2, "Data is too big"
  let size = frameSize * channels
  result = newCArray[opusInt16](size)
  for i in 0..<(data.len div 2):
    # Merge two bytes into one 16 bit integer
    result[i] = cast[opusInt16](
      (data[2 * i + 1].ord shl 8) or
      data[2 * i].ord
    )

proc toPCMData*[T](data: sink string, opus: OpaqueOpusObject[T]): PCMData =
  ## Like the other `toPCMData` except it uses the settings from an OpusEncoder_ or OpusDecoder_
  result = data.toPCMData(opus.frameSize, opus.channels)

proc `$`*(pcm: PCMData): string =
  result = newString(pcm.len * 2)
  for i in 0..<pcm.len:
    # Split a 16 bit integer into two bytes
    result[2 * i] = cast[char](pcm[i] and 0xFF)
    result[2 * i + 1] = cast[char]((pcm[i] shr 8) and 0xFF)

proc adjustVolume*(pcm: var PCMData, mul: float) =
  ## Adjusts the volume by `mul`. Performs in place
  runnableExamples:
    let
      frameSize = 960
      channels = 2
      sample = "tests/test.raw".readFile()[0..<(frameSize * channels * 2)]
    var data = sample.toPCMData(frameSize, channels)
    data.adjustVolume(1) # Makes the volume be the same
    data.adjustVolume(0.5) # Volume is now half as loud
  for sample in pcm.mitems:
    let newValue = sample * mul
    # Make sure the value is a valid int16 number
    # TODO: Surely there is a less jank way of doing this?
    sample = newValue.int64.clamp(opusInt16.low.int32, opusInt16.high.int32).opusInt16

proc adjustedVolume*(pcm: PCMData, mul: float): PCMData =
  ## Adjusts the volume by `mul`. Returns a new copy of PCMData_ with the adjusted volume
  result = pcm
  result.adjustVolume(mul)