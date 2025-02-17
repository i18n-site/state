use axum::{Router, routing::get};
use smtp::smtp;

use crate::url;

pub fn route(mut router: Router) -> Router {
  macro_rules! get {
    ($path: expr, $mod:expr) => {
      router = router.route(concat!("/", $path), get($mod));
    };
  }

  get!("", url::index::get);
  // get!("smtp", smtp::smtp);

  return router;
}
