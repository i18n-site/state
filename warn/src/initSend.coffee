#!/usr/bin/env coffee

import { EmailMessage } from 'cloudflare:email'

> @8v/send > lark Push

sendmail = (sender, from_name, from, to, subject, txt) =>
  raw = [
    'MIME-Version: 1.0'
    'Message-ID: '+ Buffer.from(crypto.getRandomValues(new Uint8Array(32))).toString('base64url')
    "From: #{JSON.stringify(from_name)}<#{from}>"
    "To: #{to}"
    "Subject: #{subject}"
    'Content-Type: text/plain; charset=UTF-8'
    ''
    txt
  ].join('\r\n')
  message = new EmailMessage(
    from, to, raw
  )
  sender.send(message)

sendbind = ({
  MAIL
  NAME
  MAIL_FROM
  MAIL_TO
}) => (title, msg, url) =>
  sendmail(
    MAIL
    NAME
    MAIL_FROM
    MAIL_TO
    title
    msg + if url then ('\n' + url) else ''
  )

export default (env)=>
  lark(env.LARKBOT)
  Push.mail(sendbind)(env)
  return
