#!/usr/bin/env coffee

> zx/globals:
  path > dirname join
  smol-toml > parse
  @3-/read

$.verbose = true

ROOT = dirname import.meta.dirname

cd ROOT


deploy = =>
  try
    await $"fly deploy"
  catch err
    {
      stderr
    } = err
    if stderr.includes "Could not find App "
      {
        app
      } = parse read join ROOT, 'fly.toml'
      await $"flyctl apps create #{app}"
      await deploy()
      return
    throw err
  return

await deploy()
process.exit()

