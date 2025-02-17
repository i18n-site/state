use axum::{routing::get, Router};

use crate::url;

pub fn route(mut router: Router) -> Router {
  macro_rules! get {
    ($path: expr, $mod:expr) => {
      router = router.route(concat!("/", $path), get($mod));
    };
  }

  get!("", url::index::get);
  get!("smtp", smtptls::smtptls);

  return router;
}
