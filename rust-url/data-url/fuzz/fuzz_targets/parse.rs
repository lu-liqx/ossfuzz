#![no_main]
use libfuzzer_sys::fuzz_target;
//use data_url::{DataUrl, mime};
//use data_url::lib::process;
fuzz_target!(|data: &[u8]| {
    // fuzzed code goes here
       if let Ok(utf8) = std::str::from_utf8(data) {
       let _ = data_url::DataUrl::process(utf8);  
   }
});
