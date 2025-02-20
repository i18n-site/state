#!/usr/bin/env coffee

> @3-/cfmail

export default (
  {
    MAIL
    NAME
    MAIL_FROM
    MAIL_TO
  }
) =>
  (
    title
    txt=''
    url=''
  )=>
    if url
      if txt
        txt += '\n'
      txt += url
    cfmail(
      MAIL
      NAME
      MAIL_FROM
      MAIL_TO
      title
      txt
    )

