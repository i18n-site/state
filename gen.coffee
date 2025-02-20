#!/usr/bin/env coffee

> fs > readdirSync
  @3-/write
  path > join
  json5

envDump = (obj) =>
  Object.entries(obj).map(
    ([key, value]) =>
      key+'='+JSON.stringify(value)
  ).join('\n')

ROOT = import.meta.dirname

CONF = join ROOT, 'conf'
IP_CONF = join CONF, 'ip'

TIP = 'DONT\'T EDIT ! use state/gen.coffee generate\n'

IPV4 = {}
IPV6 = {}

await Promise.all readdirSync(IP_CONF).map (fp)=>
  (await import(join(IP_CONF,fp))).default.forEach(
    ([host,v4,v6])=>
      IPV4[host] = v4
      IPV6[host] = v6
      return
  )
  return

save = (obj)=>
  for [k,v] from Object.entries(obj)
    o = {}
    o[k] = v
    write(
      join(
        ROOT,'conf/rust/'+k+'.env'
      )
      '# '+TIP+envDump(o)+'\n'
    )
    js = """
// #{TIP}
const #{k} = #{json5.stringify v,null,2};

export const #{k}_HOST = new Map();

Object.entries(#{k}).forEach(([host, ip]) => {
  #{k}_HOST.set(ip, host);
});

export default #{k};
    """
    write(
      join CONF, k+'.js'
      js
    )
  return

save({IPV4, IPV6})

