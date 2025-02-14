> ./Conn.js
  ./conf/IPV4.js:@ > IPV4_HOST
  ./conf/_tmpl.js > CONF
  ./raise.js

_ping = (
  hostname
  [
    conn
    q
    q1
  ]
)=>
  isReadOnly = =>
    (
      await q1 'SELECT @@read_only'
    )['@@read_only']

  read_only = await isReadOnly()
  slave_state = await q1('SHOW SLAVE STATUS')

  if slave_state # slave
    is_master = 0
    if not read_only
      await q('SET GLOBAL read_only=1')
      if not await isReadOnly()
        raise 'slave not read-only'

    {
      Slave_IO_Running
      Slave_SQL_Running
      Last_Error
    } = slave_state

    if not (
      Slave_IO_Running == 'Yes' and Slave_SQL_Running == 'Yes'
    )
      raise {
        Last_Error
        Slave_IO_Running
        Slave_SQL_Running
      }
  else
    is_master = 1
    if read_only
      await q('SET GLOBAL read_only=0')
      if await isReadOnly()
        raise 'master is read-only'
  return is_master

ping = (host)=>
  conn = await Conn({
    host: IPV4[host]
    rowsAsArray: false
    ...CONF
  })

  try
    return await _ping(host, conn)
  finally
    conn[0].close()
  return

export default (host_li)=>
  master_li = []
  slave_li = []
  err_li = []
  for i, pos in await Promise.allSettled host_li.map(ping)
    host = host_li[pos]
    if i.reason
      err_li.push host + ': ' + i.reason?.message+'\n'
    else if i.value
      master_li.push host
    else
      slave_li.push host

  { length } = master_li
  if length != 1
    err = "#{length} master"
    if length
      err += ':' + master_li.join(' , ')
    err_li.push err
  raise err_li
  slave_li.sort()
  return [master_li[0],slave_li]

