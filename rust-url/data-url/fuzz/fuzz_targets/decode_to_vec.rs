#![no_main]
use libfuzzer_sys::fuzz_target;
//use data_url::{DataUrl, mime};
use data_url::forgiving_base64::decode_to_vec;

fuzz_target!(|data: &[u8]| {
    // fuzzed code goes here
  // let _ =data_url::forgiving_base64::InvalidBase64::decode_to_vec(data);
    let _ =decode_to_vec(data);
});
