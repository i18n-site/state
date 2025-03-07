import Pg from "./Pg.js"
import toli from "@8v/toli"
import sec from "@3-/time/sec.js"

export default async function () {
	const pg = Pg(this.env),
		ok = {},
		err = {},
		now = sec()
	;(
		await pg`SELECT kind,err,name,ts,ts_next,state FROM state.heartbeat`.values()
	).forEach(([kind, e, name, ts, ts_next, state]) => {
		// console.log(kind,name,ts_next, now)
		const expire = ts_next < now,
			args = [name, ts],
			t = expire || e ? (args.push(+expire), err) : ok

		let li = t[kind]
		if (!li) {
			t[kind] = li = []
		}
		if (null !== state) {
			args.push(state)
		}
		li.push(args)
	})

	const response = new Response(JSON.stringify([err, ok].map(toli)))
	response.headers.set("Expires", "0")
	return response
}
