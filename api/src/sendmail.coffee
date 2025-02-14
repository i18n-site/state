#!/usr/bin/env coffee

> @3-/cfmail

export default (
  {
    MAIL
    NAME
    MAIL_FROM
    MAIL_TO
  }
  title
  txt
) =>
  cfmail(
    MAIL
    NAME
    MAIL_FROM
    MAIL_TO
    title
    txt
  )

