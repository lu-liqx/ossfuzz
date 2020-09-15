#![no_main]
use libfuzzer_sys::fuzz_target;
//use data_url::FragmentIdentifier::to_precent_encoded;
use data_url::DataUrl::FragmentIdentifier;
fuzz_target!(|data: &[u8]| {
    // fuzzed code goes here
  //  to_percent_encoded   
   if let Ok(utf8) = std::str::from_utf8(data) {
       let _ =to_precent_encoded(utf8);
   } 
});
