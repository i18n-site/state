#!/usr/bin/env bun

> ./gen/CRON.js
  ./lib/getMap.js
  ./lib/getSet.js
  ./STATE.js > OK Ok Err
  @3-/nowts
  ansis > redBright
  js-yaml > dump

TASK = []

set = (task, n=0)=>
  li = TASK[n]
  if not li
    TASK[n] = li = []
  li.push task
  return

do =>
  li = []
  for [kind, group, mod] from CRON
    for [group, item_li] from Object.entries(
      group
    )
      env = [
        mod
        item_li
        kind
        group
      ]
      for item from item_li
        li.push [
          item
          env
        ]

  TASK.push li
  return

run = (logerr,task,now)=>
  [item, env] = task
  [mod, ...args] = env
  [item_li, kind, group] = args

  r = await mod.default logerr, item, ...args
  t = [now]
  if r != undefined
    t.push r

  getMap(
    getMap(OK,kind)
    group
  )[
    item
  ] = t
  return

gSet = (map, kind, group)=>
  getSet(
    getMap(map,kind)
    group
  )

setHas = (map, kind, group, item)=>
  t = map[kind]
  if not t
    return
  t = t[group]
  if not t
    return
  t.has item

export default =>
  li = TASK.shift()

  if not li
    return

  now = nowts()

  item_err = {}

  logerr = (kind, group, item, err) =>
    gSet(
      item_err
      kind
      group
    ).add item
    if err
      if err instanceof Error
        err = err.toString()
      else if not err.constructor != String
        err = dump err
    Err(kind,group,item,err,now)
    return

  done = {}
  timer = setTimeout(
    =>
      for [item, [mod, item_li, kind, group]] from li
        if not setHas(done,kind,group,item)
          logerr(kind, group, item, 'timeout')
      return
    6e4
  )

  try
    await Promise.all li.map (task)=>
      [item, [mod, item_li, kind, group]] = task
      try
        await run logerr.bind(
          null, kind, group, item
        ),task,now
        gSet(done,kind,group).add item
      catch err
        console.error redBright(
          [kind, group, item].join(' → ')
        ), err
        set(task)
      return
  finally
    clearTimeout timer

    for task from li
      [item, [mod, item_li, kind, group]] = task
      has_err = setHas(item_err,kind,group,item)
      set(
        task
        if has_err then 0 else Math.max(
          0
          (mod.interval-1) or 0
        )
      )
      if not has_err
        Ok(kind, group, item)
  return
