use axum::{Router, routing::get};

use crate::url;

// #[axum::debug_handler]
// pub async fn smtp() -> Result<impl IntoResponse, impl IntoResponse> {
//   match smtp::smtp().await {
//     Ok(_) => Ok(()),
//     Err(e) => Err((StatusCode::INTERNAL_SERVER_ERROR, e.to_string())),
//   }
// }

pub fn route(mut router: Router) -> Router {
  macro_rules! get {
    ($path: expr, $mod:expr) => {
      router = router.route(concat!("/", $path), get($mod));
    };
  }

  get!("", url::index::get);
  // get!("smtp", smtp);

  router
}
