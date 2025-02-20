> @8v/retry
  ./raise.js
  ioredis:Redis
  ./conf/kvrocks.js:KVROCKS > SENTINEL_PORT:PORT SENTINEL_PASSWORD:PASSWORD
  ./conf/IPV4.js:@ > IPV4_HOST
  ./Ver.js

HOST_GROUP = new Map
GROUP_LI = []

Object.entries(KVROCKS).forEach ([name, host_li])=>
  for host from host_li
    HOST_GROUP.set host, name
  GROUP_LI.push name
  return

ping = retry (host, pos)=>
  redis = new Redis({
    host: IPV4[host]
    port: PORT
    password: PASSWORD
  })
  err_li = []
  try
    if pos == 0
      group_set = new Set GROUP_LI
      for li from await redis.sentinel 'masters'
        len = li.length
        n = 0
        + host, num_slaves, num_other_sentinels, port
        while n < len
          key = li[n++]
          val = li[n++]
          switch key
            when 'port'
              port = val
            when 'ip'
              host = IPV4_HOST.get val
              group_set.delete HOST_GROUP.get(host)
            when 'num-slaves'
              num_slaves = Number.parseInt val
            when 'num-other-sentinels'
              num_other_sentinels = Number.parseInt val
        if num_slaves < 2
          err_li.push host+':'+port+' 只有 '+num_slaves+' 从库'
        if num_other_sentinels < 2
          err_li.push host+':'+SENTINEL_PORT+' 只有 '+num_other_sentinels+' 哨兵'
      if group_set.size > 0
        err_li.push "miss cluster "+[...group_set].join(' ')
    return await Ver(redis)
  finally
    redis.disconnect()
  raise err_li
  return
#
export default (host_li)=>
  err_li = []
  + ver
  for i, pos in await Promise.allSettled host_li.map(ping)
    host = host_li[pos]
    if i.reason
      err_li.push host + ': ' + i.reason?.message+'\n'
    else
      if pos
        if i.value != ver
          err_li.push 'ver mismatch : ' + host_li[0] + ':'+ ver + ' != ' + host + ':'+i.value
      else
        ver = i.value
  raise err_li
  return ver

