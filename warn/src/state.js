// const cmp0 = (a,b)=>a[0].localeCompare(b[0])
//
// const sortmap = (map)=>{
//   map = [...Object.entries(map)]
//   console.log(JSON.stringify(map))
//   map.sort(cmp0)
//   map.forEach((li)=>{
//     li.sort(cmp0)
//   })
//   return map
// }

export default async (req, env, pg) => {
  const ok = {}, err = {};

  (
    await pg`SELECT kind,err,name,ts,ts_next,state FROM state.heartbeat`
      .values()
  ).forEach(
    ([kind, e, ...args]) => {
      const t = e ? err : ok;
      let li = t[kind];
      if (!li) {
        t[kind] = li = [];
      }
      if (null === args[3]) {
        args.pop();
      }
      li.push(args);
    },
  );

  const response = new Response(JSON.stringify(
    [err, ok],
  ));
  response.headers.set("Expires", "0");
  return response;
};
