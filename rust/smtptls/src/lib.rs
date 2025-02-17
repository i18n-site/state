use aok::{OK, Void};

genv::s!(SMTP_HOST_LI);

pub async fn smtptls() -> Void {
  dbg!(&*SMTP_HOST_LI);
  OK
}
