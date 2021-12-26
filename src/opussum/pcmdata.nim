import common

type
  PCMData* = object
    ## Stores raw pcm data.
    ## * **len**: Length of the data (number of int16 values in the array)
    len*: int
    data*: ptr UncheckedArray[opusInt16]

proc toPCMBytes*(data: sink string, frameSize, channels: int): PCMData =
  ## Converts a string to pcm bytes
  assert data.len <= frameSize * channels * 2, "Data is too big"
  let size = frameSize * channels
  result.len = size
  result.data = cast[ptr UnCheckedArray[opusInt16]](createShared(opusInt16, size))
  # Convert to little endian int16
  for i in 0..<(data.len div 2):
    result.data[i] = cast[opusInt16](
      (data[2 * i + 1].ord shl 8) or
      data[2 * i].ord
    )

proc toPCMBytes*[T](data: sink string, opus: OpaqueOpusObject[T]): PCMData =
  ## Like the other `toPCMBytes` except it uses the settings from an OpusEncoder_ or OpusDecoder_
  result = data.toPCMBytes(opus.frameSize, opus.channels)

proc `==`*(x, y: PCMData): bool =
  ## Check if two PCMBytes_ are equal by comparing each byte
  if x.len == y.len:
    for i in 0..<x.len:
      if x.data[i] != y.data[i]:
        return false

proc `$`*(pcm: PCMData): string =
  result = newString(pcm.len * 2)
  for i in 0..<pcm.len:
    # Convert endianess
    result[2 * i] = cast[char](pcm.data[i] and 0xFF)
    result[2 * i + 1] = cast[char]((pcm.data[i] shr 8) and 0xFF)

proc `=destroy`(pcm: var PCMData) =
  if pcm.data != nil:
    freeShared pcm.data
    pcm.data = nil