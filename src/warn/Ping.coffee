> @3-/nowts
  @8v/needwarn
  @8v/hsec
  @8v/pg > LI EXE UNSAFE
  @8v/kind-name:kindName
  @8v/notify

export default =>
  now = nowts()

  [
    err_li
    expire_li
    # recover_li
  ] = await Promise.all [
    LI"SELECT id,kind,name,warn,ts,state FROM state.heartbeat WHERE err=true AND ts_next>=#{now}"
    LI"SELECT id,kind,name,warn,ts_next FROM state.heartbeat WHERE ts_next<#{now}"
    # LI"SELECT * FROM fn.heartbeatRecover()"
  ]

  warn_incr_id_li = []
  ing = []

  # console.log JSON.stringify {err_li, expire_li, recover_li},null,2
  sendwarn = (type,li)=>
    for [id,kind,name,warn,ts,state] in li
      diff = now - ts
      # console.log(diff, warn,needwarn(diff, warn))
      if needwarn(diff, warn)
        warn_incr_id_li.push id

        msg = [
          '第'+(1+warn)+'次报警\n故障持续 '+hsec(diff)
        ]
        if state
          msg.unshift state

        ing.push notify(
          kindName(kind, name) + ' ' + type + ' ❌'
          msg.join('\n')
        )
    return

  sendwarn('故障', err_li)
  sendwarn('监控挂了', expire_li)

  if warn_incr_id_li.length
    ing.push UNSAFE(
      "UPDATE state.heartbeat SET warn=warn+1 WHERE err=true OR ts_next<#{now} AND id IN (#{warn_incr_id_li.join(',')})"
    )

  for i from await Promise.allSettled ing
    if i.reason
      throw i.reason
  return
