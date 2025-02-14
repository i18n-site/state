#!/usr/bin/env coffee

> @x0/env:ENV

import { Client } from 'postgres'

Deno.serve =>
  {
    PG_URL
  } = ENV

  new Response('good1')

