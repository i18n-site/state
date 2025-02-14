#!/usr/bin/env coffee
> @8v/honotoken

export default honotoken ->
  console.log 'param', @req.param('token'), @env.API_TOKEN
  return '2'
