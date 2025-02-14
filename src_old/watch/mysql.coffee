> ../lib/MySql.js
  ../lib/getMap.js
  ../../conf/IPV4.js:@ > IPV4_HOST
  ../../conf/mysql.js > CONF
  @3-/retry

# 单位分钟
export interval = 1

export default (logerr, item, item_li)=>
  host = IPV4[item]
  [
    conn
    q
    q1
  ] = await MySql({
    host
    rowsAsArray: false
    ...CONF
  })

  read_only = (
    await q1 'SELECT @@read_only'
  )['@@read_only']

  state = await q1('SHOW SLAVE STATUS')

  if state # slave
    is_master = 0
    if not read_only
      logerr 'slave not read-only'
      await q('SET GLOBAL read_only=1')

    {
      Slave_IO_Running
      Slave_SQL_Running
      Last_Error
    } = state
    if not (
      Slave_IO_Running == 'Yes' and Slave_SQL_Running == 'Yes'
    )
      logerr {
        Last_Error
        Slave_IO_Running
        Slave_SQL_Running
      }
  else
    is_master = 1
    if read_only
      logerr 'master is read-only'
      await q('SET GLOBAL read_only=0')

    slave_set = new Set item_li
    slave_set.delete item
    for i from await q('SHOW SLAVE HOSTS')
      slave_set.delete i.Host
    if slave_set.size
      logerr 'lost slave '+[
        ...slave_set
      ].join(' & ')

  conn.close()
  return is_master
