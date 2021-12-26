import unittest
import opussum
import std/streams
import std/os
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
    let encoder = createEncoder(48000, 2, 960, Audio)
    rawData = newFileStream("tests/test.raw", fmRead)
    let
      pcmBytes = rawData.readStr(1920 * 2).toPCMBytes(encoder)
      encodedData = encoder.encode(pcmBytes)
      decodedData = decoder.decode(encodedData)

suite "CTL codes":
  let encoder = createEncoder(48000, 2, 960, Audio)
  test "Get a value":
    check encoder.performCTLGet(getBitrate) == 120000

  test "Set a value":
    encoder.performCTLSet(setBitrate, 36000)
    check encoder.performCTLGet(getBitrate) == 36000
