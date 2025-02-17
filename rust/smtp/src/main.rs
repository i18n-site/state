use aok::{OK, Void};

genv::s!(SMTP_HOST_LI);

pub fn smtp() -> Void {
  OK
}

// use aok::{OK, Result, Void};
// use axum::{Router, extract::State, http::StatusCode, response::IntoResponse, routing::get};
// use shuttle_runtime::{__internals::Context, SecretStore};
//
// mod ping;
// pub use ping::ping;
// mod err;
// pub use err::Err;
//
// pub static mut RUNED: u64 = 0;
//
// async fn run(secrets: SecretStore) -> Void {
//   macro_rules! secret {
//     ($($name:ident),*) => {
//       $(
//         #[allow(non_snake_case)]
//         let $name = {
//           let name = stringify!($name);
//           secrets.get(name).context(format!("miss secret {}", name))?
//         };
//       )*
//     };
//   }
//   secret!(
//     PG_URL,
//     SMTP_HOST_LI,
//     SMTP_PASSWORD,
//     SMTP_PORT,
//     SMTP_USER,
//     IPV4,
//     IPV6
//   );
//
//   let host_li = SMTP_HOST_LI.split(" ").collect::<Vec<_>>();
//
//   let port: u16 = SMTP_PORT.parse()?;
//   if let Some(p) = SMTP_USER.find('@') {
//     let smtp_host = &SMTP_USER[p + 1..];
//
//     macro_rules! ping {
//       ($host_ip:ident) => {
//         ping(
//           smtp_host,
//           port,
//           &SMTP_USER,
//           &SMTP_PASSWORD,
//           &host_li,
//           &$host_ip,
//         )
//         .await?;
//       };
//     }
//
//     ping!(IPV4);
//     // ping!(IPV6);
//   } else {
//     Err(Err::Msg(format!("{SMTP_USER} not include @")))?
//   }
//
//   OK
// }
//
// #[allow(static_mut_refs)]
// async fn index(State(secrets): State<SecretStore>) -> Result<impl IntoResponse, impl IntoResponse> {
//   match run(secrets).await {
//     Err(err) => Err((StatusCode::INTERNAL_SERVER_ERROR, err.to_string())),
//     Ok(_) => {
//       unsafe { RUNED += 1 };
//       Ok(unsafe { RUNED.to_string() })
//     }
//   }
// }
//
// #[shuttle_runtime::main]
// async fn axum(#[shuttle_runtime::Secrets] secrets: SecretStore) -> shuttle_axum::ShuttleAxum {
//   // let pg_url = secrets.get("PG_URL").context("miss secret PG_URL")?;
//   // let smtp_host_li = secrets
//   //   .get("SMTP_HOST_LI")
//   //   .context("miss secret SMTP_HOST_LI")?;
//   // dbg!(pg_url, smtp_host_li);
//
//   let router = Router::new().route("/", get(index)).with_state(secrets);
//   Ok(router.into())
//   // Ok(run(secrets).await.context("failed to run axum")?)
// }
