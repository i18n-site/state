use std::{
  collections::HashMap,
  env,
  fmt::Display,
  net::{Ipv4Addr, Ipv6Addr},
  str::FromStr,
};

use sonic_rs::from_slice_unchecked;
use static_init::dynamic;

pub fn from_env<Ip: FromStr>(name: &str) -> HashMap<String, Ip>
where
  <Ip as FromStr>::Err: Display,
{
  let mut map = HashMap::new();

  // 从环境变量读取 JSON 字符串
  let json_str = match env::var(name) {
    Ok(val) => val,
    Err(_) => {
      tracing::warn!("未设置环境变量 {name} ");
      return map;
    }
  };

  let parsed_map: Result<HashMap<String, String>, _> =
    unsafe { from_slice_unchecked(json_str.as_bytes()) };

  let parsed_map = match parsed_map {
    Ok(m) => m,
    Err(e) => {
      tracing::error!("环境变量 {name} 中解析 JSON 失败: {e}");
      return map; // 解析失败，返回空 HashMap
    }
  };

  for (key, ip_str) in parsed_map {
    match ip_str.parse() {
      Ok(ip_addr) => {
        map.insert(key, ip_addr);
      }
      Err(e) => {
        tracing::error!("解析 IP 地址 {} 失败: {}", ip_str, e);
      }
    }
  }

  map
}

#[dynamic]
pub static IPV4: HashMap<String, Ipv4Addr> = from_env("IPV4");

#[dynamic]
pub static IPV6: HashMap<String, Ipv6Addr> = from_env("IPV6");
