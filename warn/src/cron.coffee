> @3-/nowts
  @8v/needwarn
  @8v/hsec
  @8v/send

export default (env, {LI,EXE,UNSAFE})=>
  now = nowts()

  [
    err_li
    expire_li
    recover_li
  ] = await Promise.all [
    LI"SELECT id,kind,name,warn,ts,state FROM state.heartbeat WHERE err=true AND #{now}<=ts_next"
    LI"SELECT id,kind,name,warn,ts_next FROM state.heartbeat WHERE #{now}>ts_next"
    LI"SELECT * FROM fn.heartbeatRecover()"
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
        msg = '故障持续 '+hsec(diff)
        if state
          msg += '\n'+state
        ing.push send(
          '❌ ' + kind + ' ' + name + ' ' + type
          msg
        )
    return

  sendwarn('出错了', err_li)
  sendwarn('监控挂了', expire_li)

  if warn_incr_id_li.length
    ing.push UNSAFE(
      "UPDATE state.heartbeat SET err=true AND warn=warn+1 WHERE id IN (#{warn_incr_id_li.join(',')})"
    )

  for [id,kind,name,warn] in recover_li
    ing.push send('✅ ' + kind + ' ' + name, '持续时间 '+hsec(warn))

  for i from await Promise.allSettled ing
    if i.reason
      throw i.reason
  console.log 'done !!!!'
  return
