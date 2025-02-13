> ./lib/warn.js
  ./lib/recover.js
  ./lib/getMap.js

export OK = {}

_needWarn = (diff, n)=>
  if diff > 600 and diff < 3600
    return n < 2
  if diff > 3600 and diff < 86400
    return n < 3
  return (n - 2) < diff / 86400

needWarn = (ts, pre)=>
  [begin, warn_count] = pre
  if _needWarn(ts - begin, warn_count)
    ++pre[1]
    return 1
  return

rmIfEmpty = (map, key, val)=>
  if not Object.keys(val).length
    delete map[key]
  return

rm = (map, key, item)=>
  val = map[key]
  if not val
    return
  if item of val
    delete val[item]
    rmIfEmpty(map, key, val)
    return 1
  return

export ERR = {}

export Err = (kind, group, item, err, ts)=>
  if err
    err = err.toString()
    map = getMap(getMap(ERR, kind), group)

    pre = map[item]
    if pre
      pre[2] = err
      if not needWarn(ts,pre)
        return
    else
      map[item] = [
        ts
        # warn count
        1
        err
      ]
    warn kind, group, item, err
  else
    err_kind = ERR[kind]
    if err_kind and rm(err_kind, group, item)
      rmIfEmpty(ERR, kind, err_kind)
      recover kind, group, item
  return

export Ok = (kind, group, item)=>
  Err kind, group, item
  return
