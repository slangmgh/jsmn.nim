import ../jsmn, strutils

type
  TestToken = object
    kind: JsmnKind
    value: string
    start, stop, size: int

proc initTok(t: tuple[k: JsmnKind; x, y, z: int]): TestToken =
  TestToken(kind: t.k, value: "", start: t.x, stop: t.y, size: t.z)

proc initTok(t: tuple[k: JsmnKind; s: string; x: int]): TestToken =
  TestToken(kind: t.k, value: t.s, start: -1, stop: -1, size: t.x)

proc initTok(t: tuple[k: JsmnKind; s: string]): TestToken =
  TestToken(kind: t.k, value: t.s, start: -1, stop: -1, size: -1)

proc check[Ty](s: string, status, numtok: int, x: varargs[Ty, initTok]) =
  var t = newSeq[JsmnToken](numtok)
  let r = parseJson(s, t)
  if r != status:
    let msg = format("status is $1, not $2", r, status)
    assert false, msg
  if r >= 0:
    for i in 0 ..< numtok:
      if t[i].kind != x[i].kind:
        let msg = format("token $1 kind is $2, not $3", i, t[i].kind, x[i].kind)
        assert false, msg
      if x[i].start != -1 and x[i].stop != -1:
        if t[i].start != x[i].start:
          let msg = format("token $1 start is $2, not $3", i, t[i].start, x[i].start)
          assert false, msg
        if t[i].stop != x[i].stop:
          let msg = format("token $1 last is $2, not $3", i, t[i].stop, x[i].stop)
          assert false, msg
      if x[i].size != -1 and t[i].size != x[i].size:
        let msg = format("token $1 size is $2, not $3", i, t[i].size, x[i].size)
        assert false, msg
      if s != "" and x[i].value != "":
        let n = t[i].stop - t[i].start
        let p = substr(s, t[i].start, n)
        if len(x[i].value) != n or p != x[i].value:
          let msg = format("token $1 value is $2, not $3", i, p, x[i].value)
          assert false, msg

block: # Empty
  check("{}", 1, 1, (JSMN_OBJECT, 0, 2, 0))
  check("[]", 1, 1, (JSMN_ARRAY, 0, 2, 0))
  check("[{},{}]", 3, 3,
    (JSMN_ARRAY, 0, 7, 2),
    (JSMN_OBJECT, 1, 3, 0),
    (JSMN_OBJECT, 4, 6, 0))

block: # Primitive
  check("{\"boolVar\" : true }", 3, 3,
    (JSMN_OBJECT, -1, -1, 1),
    (JSMN_STRING, "boolVar", 1),
    (JSMN_PRIMITIVE, "true"))
  check("{\"boolVar\" : false }", 3, 3,
    (JSMN_OBJECT, -1, -1, 1),
    (JSMN_STRING, "boolVar", 1),
    (JSMN_PRIMITIVE, "false"))
  check("{\"nullVar\" : null }", 3, 3,
    (JSMN_OBJECT, -1, -1, 1),
    (JSMN_STRING, "nullVar", 1),
    (JSMN_PRIMITIVE, "null"))
  check("{\"intVar\" : 12}", 3, 3,
    (JSMN_OBJECT, -1, -1, 1),
    (JSMN_STRING, "intVar", 1),
    (JSMN_PRIMITIVE, "12"))
  check("{\"floatVar\" : 12.345}", 3, 3,
    (JSMN_OBJECT, -1, -1, 1),
    (JSMN_STRING, "floatVar", 1),
    (JSMN_PRIMITIVE, "12.345"))
