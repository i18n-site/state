#!/usr/bin/env coffee

> zx/globals:
  path > dirname join
  smol-toml > parse
  @3-/read

$.verbose = true

remove = =>
  {stdout} = await $"flyctl machines list -j"
  li = JSON.parse(stdout)
  if li.length > 1
    for  {id} from li.slice(1)
      await $"flyctl machine remove #{id} --force"
  return

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
      await remove()
      return
    throw err
  return

await deploy()
process.exit()

await init()
