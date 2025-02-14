#!/usr/bin/env coffee

import { EmailMessage } from 'cloudflare:email'

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
  sendmail(
    MAIL
    NAME
    MAIL_FROM
    MAIL_TO
    title
    txt
  )

