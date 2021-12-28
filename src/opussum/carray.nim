
## Small abstraction around the common `ptr T` parameters in procs

type
  CArray*[T] = object
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
  ## Check if two arrays are equal by comparing each byte
  if x.len == y.len:
    for i in 0..<x.len:
      if x[i] != y[i]:
        return false

proc pass*[T](arr: CArray[T]): ptr T =
  ## Passes pointer to first item in array, useful when interfacing with procs that take `ptr T` parameter
  result = addr arr.internal[0]

proc `=destroy`[T](arr: var CArray[T]) =
  if arr.internal != nil:
    freeShared arr.internal
    arr.internal = nil
