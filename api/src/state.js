import Pg from "./Pg.js"
import toli from '@8v/toli'

export default async function () {
	const pg = Pg(this.env),
		ok = {},
		err = {}

	;(
		await pg`SELECT kind,err,name,ts,ts_next,state FROM state.heartbeat`.values()
	).forEach(([kind, e, ...args]) => {
		const t = e ? err : ok
		let li = t[kind]
		if (!li) {
			t[kind] = li = []
		}
		if (null === args[3]) {
			args.pop()
		}
		li.push(args)
	})

	const response = new Response(
    JSON.stringify(
      [
        err, ok
      ].map(toli)
    )
  )
	response.headers.set("Expires", "0")
	return response
}
