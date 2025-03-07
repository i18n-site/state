#!/usr/bin/env coffee

> @8v/honotoken
  @8v/send/fromEnv.js
  @8v/send/Send.js
  ./sendmail.js

export default honotoken ->
  {
    title
    txt
    url
  } = await @req.json()

  [send_li,name_li] = conf = fromEnv @env

  send_li.push sendmail(@env)
  name_li.push 'mail'

  await Send(conf)(
    title
    txt
    url
  )

  return
