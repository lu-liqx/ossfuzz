#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    // fuzzed code goes here
});
#![no_main]
#[macro_use] extern crate libfuzzer_sys;
extern crate url;
use std::str;
parse_opaque
fuzz_target!(|data: &[u8]| {
    if let Ok(utf8) = str::from_utf8(data) {
        if let Ok(parsed) = url::Url::parse(utf8) {
            let as_str = parsed.as_str();
            assert_eq!(parsed, url::Url::parse(as_str).unwrap());
        }
    }
});

