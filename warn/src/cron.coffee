> @3-/nowts
  @8v/needwarn
  @8v/hsec
  @8v/send

export default (env, {LI,EXE})=>
  now = nowts()

  [
    err_li
    expire_li
    recover_li
  ] = await Promise.all [
    LI"SELECT id,kind,name,warn,ts,state FROM state.heartbeat WHERE err=true AND ts_next<#{now}"
    LI"SELECT id,kind,name,warn,ts_next FROM state.heartbeat WHERE ts_next>=#{now}"
    LI"SELECT * FROM fn.heartbeatRecover()"
  ]

  warn_incr_id_li = []
  ing = []

  sendwarn = (type,li)=>
    for [id,kind,name,warn,ts,state] in err_li
      diff = now - ts
      if needwarn(diff, warn)
        warn_incr_id_li.push id
        msg = '故障持续 '+hsec(diff)
        if state
          msg += '\n'+state
        ing.push warn(
          '❌ ' + kind + ' ' + name + ' ' + type
          msg
        )
    return

  sendwarn('出错了', err_li)
  sendwarn('监控挂了', expire_li)

  if warn_incr_id_li.length
    ing.push EXE"UPDATE state.heartbeat SET err=true AND warn=warn+1 WHERE id IN (#{warn_incr_id_li.join(',')})"

  for [id,kind,name] in recover_li
    ing.push send('✅ ' + kind + ' ' + name)

  for i from await Promise.allSettled ing
    if i.reason
      throw i.reason

  return
