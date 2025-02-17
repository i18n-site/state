use axum::{Router, routing::get};

use crate::url;

pub fn route(mut router: Router) -> Router {
  macro_rules! get {
    ($path: expr, $mod:ident) => {
      router = router.route($path, get(url::$mod::get));
    };
  }

  get!("/", index);
  return router;
}
