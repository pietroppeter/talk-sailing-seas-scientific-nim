## A joke with a point: `nbPython` shows code that reads as Python, and is Nim.
## The code is shown as written (highlighted as Python) and runs as Nim when the page is
## built: the macro `pythonish` rewrites a few Python habits into Nim before the compiler
## checks the types. Only what Nim's parser already accepts can be rewritten, so this is a
## small subset, not Python: no classes, no tuple unpacking, no 'single quotes' (chars in Nim),
## no list comprehensions; values of different types do not mix in a list.
##
##   def f(x):           ->  proc f(x: auto): auto
##   x = 1               ->  var x = 1 (the first time `x` is assigned)
##   [1, 2, 3]           ->  @[1, 2, 3] (a seq, so `append` works)
##   for i in range(n):  ->  for i in pyRange(n)
##   True, False, None   ->  true, false, nil
##
## and a handful of procs: print, append, `//`, `%`, `**`, float / int, f"..." strings.
import std / [macros, math, sets, strformat, strutils]
import nimib
import blocks # nbShowCode
export math, strformat

# ------------------------------------------------------------------------ the procs Python has

proc str*[T](x: T): string = $x
proc str*(x: bool): string = (if x: "True" else: "False")
proc str*[T](xs: seq[T]): string =
  result = "["
  for i, x in xs:
    if i > 0: result.add ", "
    result.add str(x)
  result.add "]"

proc print*(args: varargs[string, str]) =
  ## print("a", 1, 2.5): the arguments written as Python would, joined by spaces
  echo args.join(" ")

proc append*[T](xs: var seq[T], x: T) = xs.add x

template `//`*(a, b: int): int = a div b
template `%`*(a, b: int): int = a mod b
template `**`*(a, b: int): int = a ^ b
template `/`*(a: float, b: int): float = a / b.float
template `/`*(a: int, b: float): float = a.float / b

template f*(pattern: static string): string =
  ## f"x is {x}": Nim's own fmt, under Python's name
  fmt(pattern)

iterator pyRange*(stop: int): int =
  for i in 0 ..< stop: yield i

iterator pyRange*(start, stop: int, step = 1): int =
  var i = start
  while (step > 0 and i < stop) or (step < 0 and i > stop):
    yield i
    i += step

# ---------------------------------------------------------------------- the rewrite into Nim

proc rewrite(n: NimNode, known: var HashSet[string]): NimNode

proc hasReturn(n: NimNode): bool =
  if n.kind == nnkReturnStmt: return true
  for c in n:
    if not (c.kind == nnkCommand and c[0].eqIdent("def")) and c.hasReturn: return true

proc rewriteDef(n: NimNode): NimNode =
  ## def name(a, b): body  ->  proc name(a, b: auto): auto = body
  let signature = n[1]
  expectKind signature, nnkCall
  var params = @[ident"auto"]
  var names: HashSet[string]
  for p in signature[1 .. ^1]:
    expectKind p, nnkIdent
    params.add newIdentDefs(p, ident"auto")
    names.incl p.strVal
  var body = n[2]
  # a def sees the names of the code around it (no global keyword needed to read them)
  result = newProc(signature[0], params, rewrite(body, names))
  if not body.hasReturn:
    result.params[0] = newEmptyNode() # no return: a proc of no value, like Python's None

proc rewrite(n: NimNode, known: var HashSet[string]): NimNode =
  case n.kind
  of nnkIdent:
    case n.strVal
    of "True": ident"true"
    of "False": ident"false"
    of "None": newNilLit()
    else: n
  of nnkCommand:
    if n.len == 3 and n[0].eqIdent("def"): rewriteDef(n)
    else:
      for i in 0 ..< n.len: n[i] = rewrite(n[i], known)
      n
  of nnkAsgn:
    let value = rewrite(n[1], known)
    if n[0].kind == nnkIdent and n[0].strVal notin known:
      known.incl n[0].strVal
      newVarStmt(n[0], value)
    else:
      n[0] = rewrite(n[0], known)
      n[1] = value
      n
  of nnkBracket:
    for i in 0 ..< n.len: n[i] = rewrite(n[i], known)
    prefix(n, "@")
  of nnkForStmt:
    let iter = n[^2]
    if iter.kind == nnkCall and iter[0].eqIdent("range"):
      iter[0] = ident"pyRange"
    for i in 0 ..< n.len: n[i] = rewrite(n[i], known)
    n
  else:
    for i in 0 ..< n.len: n[i] = rewrite(n[i], known)
    n

macro pythonish*(body: untyped): untyped =
  ## the code of `body`, read as Python and rewritten into Nim
  var known: HashSet[string]
  result = rewrite(body, known)

# ------------------------------------------------------------------------------------ the block

template nbPython*(body: untyped) =
  ## shows `body` as Python (tagged "Python? Nim!") and runs it as Nim, with its output under it
  nbShowCode(getCode(body), lang = "pynim")
  nbCapture:
    pythonish(body)
