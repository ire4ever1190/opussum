
import unittest

import opussum
var encoder: OpusEncoder
test "Create encoder":
  encoder = createEncoder(48000, 2, Voip)
