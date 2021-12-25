import unittest
import opussum
import std/streams

#
# Test data comes from joystock
# Music by Joystock - https://www.joystock.org
#

var rawData = newFileStream("tests/test.raw", fmRead)

var canEncode: bool

suite "Encoder":
  var encoder: OpusEncoder
  test "Create encoder":
    encoder = createEncoder(48000, 2, 960, Voip)

  test "Encode data":
    # We want to encode 1920 data
    # Since we have bytes and PCM is int16, we need to get twice as many bytes
    discard encoder.encode(rawData.readStr(1920 * 2).toPCMBytes(encoder))
    canEncode = true
    
suite "Decoder":
  var decoder: OpusDecoder
  test "Create decoder":
    decoder = createDecoder(48000, 2, 960)

  test "Decode data":
    check canEncode
    let encoder = createEncoder(48000, 2, 960, Voip)
    rawData = newFileStream("tests/test.raw", fmRead)
    var buf: string
    let pcmBytes = rawData.readStr(1920 * 2).toPCMBytes(encoder)
    let encodedData = encoder.encode(pcmBytes)
    discard decoder.decode(encodedData)


GC_fullcollect()
