> @8v/retry
  ./conf/IPV4.js:@ > IPV4_HOST
  ./raise.js

_ping = (host)=>
  return

ping = retry (host)=>
  conn = 'TODO'
  try
    return await _ping(host)
  finally
    conn.close()
  return

export default (host_li)=>
  err_li = []

  for i, pos in await Promise.allSettled host_li.map(ping)
    host = host_li[pos]
    if i.reason
      err_li.push host + ': ' + i.reason?.message+'\n'
    else if i.value
      ``

  raise err_li
  return [master,slave_li]

