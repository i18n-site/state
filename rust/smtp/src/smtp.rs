use std::sync::Arc;

use futures::future::join_all;
use thiserror::Error;
use tokio::{
  io::{AsyncBufReadExt, AsyncWriteExt},
  net::{TcpStream, ToSocketAddrs},
};
use tokio_rustls::{
  TlsConnector,
  rustls::{self, ClientConfig, client::ServerCertVerifier},
};
use webpki;

#[derive(Error, Debug)]
pub enum SmtpError {
  #[error("网络连接错误: {0}")]
  Io(#[from] std::io::Error),

  #[error("TLS 错误: {0}")]
  Tls(#[from] rustls::Error),

  #[error("证书解析错误: {0}")]
  Webpki(#[from] webpki::Error),

  #[error("服务器不支持 STARTTLS")]
  NoStartTls,

  #[error("STARTTLS 失败: {0}")]
  StartTlsFailed(String),

  #[error("未能获取服务器证书")]
  NoCertificate,

  #[error("域名解析错误: {0}")]
  Resolve(#[from] std::io::ErrorKind),

  #[error("连接关闭: {0}")]
  ConnectClose(String),

  #[error("意外消息:{0}")]
  UnexpectedMessage(String),

  #[error("证书域名不匹配")] // 新增：证书域名不匹配
  CertificateNameMismatch,
}

// 可以选择自定义证书验证器，也可以直接使用默认的
struct CustomCertVerifier; //这里保持空白，就是rustls的默认证书校验

impl ServerCertVerifier for CustomCertVerifier {
  fn verify_server_cert(
    &self,
    end_entity: &rustls::Certificate,
    intermediates: &[rustls::Certificate],
    server_name: &rustls::ServerName,
    scts: &mut dyn Iterator<Item = &[u8]>,
    ocsp_response: &[u8],
    now: std::time::SystemTime,
  ) -> Result<rustls::client::ServerCertVerified, rustls::Error> {
    // 1. 默认验证 (包括根证书信任、链构建等)
    let webpki_verifier = rustls::client::WebPkiVerifier::new(
      rustls::RootCertStore::empty(), //空的CA，为了跳过CA校验
      None,
    );

    //这里需要先校验域名是否匹配，在进行默认验证
    let end_entity_cert = webpki::EndEntityCert::try_from(end_entity.0.as_ref())
      .map_err(|err| rustls::Error::General(err.to_string()))?;
    let dns_nameref = match server_name {
      rustls::ServerName::DnsName(name) => name,
      _ => return Err(rustls::Error::General("Invalid DNS name".into())),
    };

    end_entity_cert
      .verify_is_valid_for_dns_name(dns_nameref)
      .map_err(|err| rustls::Error::General(format!("证书域名不匹配: {}", err)))?;

    webpki_verifier.verify_server_cert(
      end_entity,
      intermediates,
      server_name,
      scts,
      ocsp_response,
      now,
    )
  }
}

#[tokio::main]
async fn main() {
  let server_name = "smtp.example.com"; // 替换为你的 SMTP 服务器域名

  // 域名解析
  match (server_name, 587).to_socket_addrs().await {
    Ok(addresses) => {
      let tasks: Vec<_> = addresses
        .map(|address| {
          let ip_address = address.ip().to_string();
          let server_name_clone = server_name.to_string(); // 克隆 server_name，因为闭包需要所有权
          tokio::spawn(async move {
            println!("Testing IP: {}, Domain: {}", ip_address, server_name_clone);
            match get_smtp_certificate_expiry(&ip_address, &server_name_clone).await {
              Ok(expiry_timestamp) => {
                println!("  证书过期时间戳: {}", expiry_timestamp);
                let now = std::time::SystemTime::now()
                  .duration_since(std::time::UNIX_EPOCH)
                  .unwrap()
                  .as_secs();
                if expiry_timestamp < now {
                  println!("  证书已过期！");
                } else {
                  println!("  证书有效。");
                }
                Ok(()) as Result<(), SmtpError>
              }
              Err(e) => {
                eprintln!("  错误: {}", e);
                Err(e)
              }
            }
          })
        })
        .collect();

      join_all(tasks).await;
    }
    Err(e) => eprintln!("域名解析失败: {:?}", e.kind()),
  }
}

async fn get_smtp_certificate_expiry(
  ip_address: &str,
  server_name: &str,
) -> Result<u64, SmtpError> {
  let port = 587;
  // 1. 建立 TCP 连接
  let mut stream = TcpStream::connect((ip_address, port)).await?;
  stream.set_read_timeout(Some(std::time::Duration::from_secs(5)))?;

  // 2. 读取并处理欢迎消息
  let mut reader = tokio::io::BufReader::new(&mut stream);
  let mut welcome_message = String::new();
  let mut line = String::new();

  loop {
    line.clear();
    let bytes_read = reader.read_line(&mut line).await?;

    if bytes_read == 0 {
      return Err(SmtpError::ConnectClose(
        "Connection closed before receiving full welcome message".into(),
      ));
    }

    welcome_message.push_str(&line);
    if line.starts_with("220 ") && line.ends_with("\r\n") {
      //对多行消息做处理
      let lines: Vec<&str> = welcome_message.split("\r\n").collect();
      if lines.len() > 1 {
        let last_line = lines[lines.len() - 2];
        if last_line.starts_with("220 ") && last_line.len() > 4 {
          break;
        }
      } else {
        break;
      }
    }
  }

  if !welcome_message.starts_with("220") {
    return Err(SmtpError::UnexpectedMessage(format!(
      "Unexpected welcome message: {}",
      welcome_message
    )));
  }

  // 3. STARTTLS 协商
  stream.write_all(b"EHLO localhost\r\n").await?; // EHLO 后的域名可以随意，但最好是合法的域名格式
  let mut resp = String::new();
  let mut line = String::new();

  loop {
    line.clear();
    let bytes_read = reader.read_line(&mut line).await?;
    if bytes_read == 0 {
      return Err(SmtpError::ConnectClose(
        "Connection closed before receiving full EHLO message".into(),
      ));
    }
    resp.push_str(&line);

    if line.ends_with("\r\n") {
      //对多行消息做处理, 寻找250开头的行
      let lines: Vec<&str> = resp.split("\r\n").collect();
      for l in lines {
        if l.starts_with("250") && l.len() > 4 {
          break;
        }
      }
    }
  }

  if !resp.contains("STARTTLS") {
    return Err(SmtpError::NoStartTls);
  }

  stream.write_all(b"STARTTLS\r\n").await?;

  welcome_message.clear();
  line.clear();

  loop {
    line.clear();
    let bytes_read = reader.read_line(&mut line).await?;

    if bytes_read == 0 {
      return Err(SmtpError::ConnectClose(
        "Connection closed before receiving full welcome message".into(),
      ));
    }

    welcome_message.push_str(&line);

    // 检查是否已经读取到完整的欢迎消息
    if line.starts_with("220 ") && line.ends_with("\r\n") {
      //对多行消息做处理
      let lines: Vec<&str> = welcome_message.split("\r\n").collect();
      if lines.len() > 1 {
        let last_line = lines[lines.len() - 2];
        if last_line.starts_with("220 ") && last_line.len() > 4 {
          break;
        }
      } else {
        break;
      }
    }
  }

  if !welcome_message.starts_with("220") {
    return Err(SmtpError::StartTlsFailed(format!(
      "STARTTLS 失败: {}",
      welcome_message
    )));
  }

  // 4. 使用 rustls 建立 TLS 连接, 开启证书验证
  let config = ClientConfig::builder()
        .with_safe_defaults()
        .with_custom_certificate_verifier(Arc::new(CustomCertVerifier {})) // 使用自定义验证器/或者默认验证器
        .with_no_client_auth();

  let server_name_dns = rustls::ServerName::try_from(server_name)?; // 使用传入的域名
  let connector = TlsConnector::from(Arc::new(config));
  let mut tls_stream = connector.connect(server_name_dns, stream).await?;

  // 5. 获取证书信息（由于已启用验证，如果证书无效，connect 会失败）
  let certs = tls_stream
    .get_ref()
    .1
    .peer_certificates()
    .ok_or(SmtpError::NoCertificate)?;
  if certs.is_empty() {
    return Err(SmtpError::NoCertificate);
  }
  let cert = &certs[0];
  let webpki_cert = webpki::EndEntityCert::try_from(cert.0.as_ref())?;
  let not_after = webpki_cert.validity().not_after;

  Ok(not_after.as_secs())
}
