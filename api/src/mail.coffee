#!/usr/bin/env coffee

> @8v/honotoken
  ./sendmail.js

export default honotoken ->
  {
    title
    txt
  } = await @req.json()
  await sendmail(
    @env
    title
    txt
  )
  return
