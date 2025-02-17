#[axum::debug_handler]
pub async fn get() -> &'static str {
  "srv"
}
