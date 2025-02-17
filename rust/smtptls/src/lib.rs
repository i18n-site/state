use aok::{OK, Void};
use axum::response::IntoResponse;

#[axum::debug_handler]
pub async fn smtptls() -> impl IntoResponse {
  ()
}
