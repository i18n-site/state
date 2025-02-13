#!/usr/bin/env coffee

> path > dirname join
  @3-/read
  @3-/write

ROOT = dirname import.meta.dirname
PACKAGE_JSON = 'package.json'

{ dependencies } =JSON.parse(
  read join(ROOT, PACKAGE_JSON)
)

cf_fp = join ROOT, 'cf', PACKAGE_JSON

cf = JSON.parse(read cf_fp)

cf.dependencies = dependencies

write(
  cf_fp
  JSON.stringify cf,null,'  '
)
