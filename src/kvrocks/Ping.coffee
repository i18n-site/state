> @8v/retry
  ./raise.js
  ioredis:Redis
  ./conf/kvrocks.js > PORT PASSWORD
  ./conf/IPV4.js
  ./Ver.js

ping = retry (host)=>
  redis = new Redis({
    host: IPV4[host]
    port: PORT
    password: PASSWORD
  })
  try
    return await Ver(redis)
  finally
    redis.disconnect()
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

