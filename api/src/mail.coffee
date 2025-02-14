#!/usr/bin/env coffee

> @8v/honotoken
  ./sendmail.js

export default honotoken ->
  {
    title
    txt
  } = await @req.json()
  console.log JSON.stringify @env
  await sendmail(
    @env
    title
    txt
  )
  return
