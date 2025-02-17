use aok::OK;
use axum::{Router, response::IntoResponse, routing::get};

use crate::url;

#[axum::debug_handler]
pub async fn smtptls() -> Result<impl IntoResponse, impl IntoResponse> {
  match smtptls::smtptls().await {
    Ok(_) => OK,
    Err(e) => Err((axum::http::StatusCode::INTERNAL_SERVER_ERROR, e.to_string())),
  }
}

pub fn route(mut router: Router) -> Router {
  macro_rules! get {
    ($path: expr, $mod:expr) => {
      router = router.route(concat!("/", $path), get($mod));
    };
  }

  get!("", url::index::get);
  get!("smtptls", smtptls::smtptls);

  return router;
}
