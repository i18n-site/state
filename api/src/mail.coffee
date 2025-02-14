#!/usr/bin/env coffee
> @8v/honotoken

export default honotoken ->
  {
    title
    txt
  } = await @req.json()
  console.log '>>>', title, txt
  return '2'
