export default (ping, conf)=>
  conf = [...Object.entries(conf)]
  =>
    li = await Promise.allSettled conf.map ping
    for i from li
      if i.reason
        console.error i.reason
    return

