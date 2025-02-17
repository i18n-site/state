use std::error;

use thiserror::Error;

#[derive(Error, Debug)]
pub enum Err {
  #[error("{0}: {1}")]
  Smtp(
    // host
    String,
    //msg
    String,
  ),
  #[error("{0}")]
  Msg(String),
}
