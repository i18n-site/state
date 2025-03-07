use std::fmt::Display;

use hsec::hsec;
use pgw::{PG, Sql};
use static_init::dynamic;
use tracing::{error, info};

/// SELECT fn.heartbeat(${kind},${name},${duration},${state})
#[dynamic]
static SQL_HEARTBEAT: Sql = PG.sql("SELECT fn.heartbeat($1,$2,$3,$4)");

/// fn.heartbeatErr(_kind,_name,_duration,_state) -> firstErr: BOOLEAN
#[dynamic]
static SQL_HEARTBEAT_ERR: Sql = PG.sql("SELECT fn.heartbeatErr($1,$2,$3,$4)");

pub enum HeartbeatResult {
  Void,
  Str(String),
}

impl From<()> for HeartbeatResult {
  fn from(_: ()) -> Self {
    HeartbeatResult::Void
  }
}

impl From<&str> for HeartbeatResult {
  fn from(s: &str) -> Self {
    HeartbeatResult::Str(s.into())
  }
}

impl From<String> for HeartbeatResult {
  fn from(s: String) -> Self {
    HeartbeatResult::Str(s)
  }
}

pub fn heartbeat<
  R: Into<HeartbeatResult> + Send,
  E: Display + Send,
  F: Send + Future<Output = Result<R, E>> + 'static,
>(
  duration: u64,
  kind: impl Into<String> + Send + 'static,
  name: impl Into<String> + Send + 'static,
  fut: F,
) {
  tokio::spawn(async move {
    // xerr::log!(PG.query(&SQL_HEARTBEAT, &[]).await);

    let kind = kind.into();
    let name = name.into();
    match fut.await {
      Ok(msg) => {
        let msg = msg.into();
        let msg = match msg {
          HeartbeatResult::Void => s_::EMPTY,
          HeartbeatResult::Str(s) => s,
        };
        if !msg.is_empty() {
          info!("{kind} {name} {msg}");
        }
        if let Ok::<i64, _>(diff) =
          xerr::ok!(pgw::q00!(&SQL_HEARTBEAT, &kind, &name, duration, msg))
        {
          if diff > 0 {
            let title = format!("{kind} {name} 恢复 ✅");
            xerr::log!(
              notify_api::send(
                &title,
                format!("{title}\n持续时间 {}", hsec(diff as u64)),
                ""
              )
              .await
            );
          }
        }
      }
      Err(err) => {
        let err = err.to_string();
        error!("{kind} {name} {err}");
        if let Ok::<bool, _>(first_err) =
          xerr::ok!(pgw::q00!(&SQL_HEARTBEAT_ERR, &kind, &name, duration, &err))
        {
          if first_err {
            let title = format!("{kind} {name} 故障 ❌");
            xerr::log!(notify_api::send(&title, format!("{title}\n{err}"), "").await);
          }
        }
      }
    }
  });
}
