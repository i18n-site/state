> @8v/mysql
  @8v/retry
  ./conf/IPV4.js:@ > IPV4_HOST
  ./conf/mysql.js > CONF IPTABLE_PORT MYSQL_PORT
  ./raise.js

_ping = (
  hostname
  {
    conn
    q
    q0
  }
)=>
  isReadOnly = =>
    (
      await q0 'SELECT @@read_only'
    )['@@read_only']

  read_only = await isReadOnly()
  slave_state = await q0('SHOW SLAVE STATUS')

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

mysqlConn = (host, port, conf={})=>
  mysql({
    host: IPV4[host]
    port
    ...CONF
    ...conf
  })

pingMysql = retry (host)=>
  {
    conn
  } = db = await mysqlConn(
    host
    MYSQL_PORT
    {
      rowsAsArray: false
    }
  )

  try
    return await _ping(host, db)
  finally
    conn.close()
  return

pingIptable = retry (host)=>
  {q00} = await mysqlConn(host, IPTABLE_PORT)
  q00 'SELECT @@hostname'

export default (host_li)=>

  ing = host_li.map pingIptable

  master_li = []
  slave_li = []
  err_li = []

  for i, pos in await Promise.allSettled host_li.map(pingMysql)
    host = host_li[pos]
    if i.reason
      err_li.push host + ':' + MYSQL_PORT + ' ' + i.reason?.message
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
  slave_li.sort()
  [master] = master_li

  for i,pos in await Promise.allSettled ing
    err = 0
    if i.reason
      host = host_li[pos]
      err = i.reason?.message
    else
      name = i.value
      if name != master
        err = 'is '+ name + ' != master ' + master

    if err
      err_li.push host + ':' + IPTABLE_PORT + ' (iptable port) : '+err

  raise err_li
  return [master,slave_li]

