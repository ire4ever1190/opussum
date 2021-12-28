import common

type
  ## TODO: Replace this with CArray?
  # PCMData* = object
    # ## Stores raw pcm data.
    # ## * **len**: Length of the data (number of int16 values in the array)
    # len*: int
    # data*: ptr UncheckedArray[opusInt16]
  PCMData* = CArray[opusInt16]

# TODO: See if this works with single channel data

proc toPCMBytes*(data: sink string, frameSize, channels: int): PCMData =
  ## Converts a string to pcm data.
  assert data.len <= frameSize * channels * 2, "Data is too big"
  let size = frameSize * channels
  result = newCArray[opusInt16](size)
  # result.data = cast[ptr UnCheckedArray[opusInt16]](createShared(opusInt16, size))
  # Convert to little endian int16
  for i in 0..<(data.len div 2):
    result[i] = cast[opusInt16](
      (data[2 * i + 1].ord shl 8) or
      data[2 * i].ord
    )

proc toPCMBytes*[T](data: sink string, opus: OpaqueOpusObject[T]): PCMData =
  ## Like the other `toPCMBytes` except it uses the settings from an OpusEncoder_ or OpusDecoder_
  result = data.toPCMBytes(opus.frameSize, opus.channels)

proc `$`*(pcm: PCMData): string =
  result = newString(pcm.len * 2)
  for i in 0..<pcm.len:
    # Convert endianess
    result[2 * i] = cast[char](pcm[i] and 0xFF)
    result[2 * i + 1] = cast[char]((pcm[i] shr 8) and 0xFF)
