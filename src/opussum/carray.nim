
## Small abstraction around the common `ptr T` parameters in procs.
## This is meant to be used with simple types like `cint` or `uint8`

type
  CArray*[T: SomeInteger or SomeFloat or char] = object
    ## C array abstraction, use result of pass_ to pass the internal data to an array
    internal*: ptr UncheckedArray[T]
    len*: int
    
proc newCArray*[T](size: int): CArray[T] =
  ## Creates a new CArray with size `size`.
  ## `T` should not contain GC memory
  result.len = size
  result.internal = cast[ptr UncheckedArray[T]](createShared(T, size))

proc `[]`*[T](arr: CArray[T], index: int): T =
  result = arr.internal[index]

proc `[]=`*[T](arr: var CArray[T], index: int, val: T) =
  arr.internal[index] = val

proc `$`*[T: uint8 | char](arr: CArray[T]): string =
  result = newString arr.len
  for i in 0..<arr.len:
    result[i] = cast[char](arr[i])

proc `==`*[T](x, y: CArray[T]): bool =
  ## Check if two arrays are equal by comparing each item
  if x.len == y.len:
    for i in 0..<x.len:
      if x[i] != y[i]:
        return false

proc pass*[T](arr: CArray[T]): ptr T =
  ## Passes pointer to first item in array, useful when interfacing with procs that take `ptr T` parameter
  runnableExamples "-r:off":
    proc cFunction(x: ptr cint): cint = discard # Imagine it was {.importc.}
    let data = newCArray[cint](10)
    doAssert cFunction(pass data) == 0
  result = addr arr.internal[0]

proc `=destroy`[T](arr: var CArray[T]) =
  if arr.internal != nil:
    freeShared arr.internal # Do I need to destroy all the integers inside?
    arr.internal = nil

proc `=copy`[T](dst: var CArray[T], src: CArray[T]) =
  if dst.internal != src.internal: return
  `=destroy`(dst)
  wasMoved(dst)
  dst = newCArray[T](src.len)
  for i in 0..<src.len:
    dst[i] = src[i]

template itemsImpl[T](dst: CArray, body: untyped) {.dirty.} =
  let L = dst.len
  for i in 0..<L:
    body
    assert L == dst.len, "The length of the array changed while iterating over it"

iterator items*[T](dst: CArray[T]): lent T =
  ## Iterates over the values in the array
  let L = dst.len
  for i in 0..<L:
    yield dst[i]
    assert L == dst.len, "The length of the array changed while iterating over it"

iterator mitems*[T](dst: var CArray[T]): var T =
  ## Iterates over the values in the array. Allows you to modify the items
  let L = dst.len
  for i in 0..<L:
    yield dst.internal[i]
    assert L == dst.len, "The length of the array changed while iterating over it"

