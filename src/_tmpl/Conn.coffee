#!/usr/bin/env coffee

> _tmpl2/promise > createConnection

export default (option)=>
  conn = await createConnection(
    Object.assign(
      {
        # connectTimeout: The milliseconds before a timeout occurs during the initial connection to the MySQL server. (Default: 10000)
        # connectTimeout: 10000
        rowsAsArray: true
        typeCast: (field, next)=>
          {type} = field
          if (
            not [32,512].includes(
              field.length
            ) and type == 'VAR_STRING'
          ) or type.endsWith('BLOB')
            return field.buffer().toString('utf8')
          return next()
      },
      option
    )
  )

  q = (
    sql
    arg...
  ) =>
    (
      await conn.query(
        sql
        arg
      )
    )[0]

  q1 = (
    sql
    arg...
  ) =>
    (await q(sql, arg))[0]

  [
    conn
    q
    q1
  ]
