#/bin/bash -eu
# Copyright 2020 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# Note: This project creates Rust fuzz targets exclusively
export CFLAGS="-O1 -fno-omit-frame-pointer -gline-tables-only -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION"
export CXXFLAGS_EXTRA="-stdlib=libc++"
export CXXFLAGS="$CFLAGS $CXXFLAGS_EXTRA"

# correct workdir
#cargo install cargo-fuzz
rustup default nightly-2020-08-14
# patch rocksdb to not link libc++ statically
#sed -i "s/link_cpp(&mut build)/build.cpp_link_stdlib(None)/" \
 #   /rust/git/checkouts/rust-rocksdb-a9a28e74c6ead8ef/72e45c3/librocksdb_sys/build.rs
# so now we need to link libc++ at the end
export RUSTFLAGS="-C link-arg=-L/usr/local/lib -C link-arg=-lc++"
export CUSTOM_LIBFUZZER_PATH="$LIB_FUZZING_ENGINE_DEPRECATED"
export CUSTOM_LIBFUZZER_STD_CXX=c++
# export CUSTOM_LIBFUZZER_STD_CXX=none 

# export fuzzing flags
RUSTFLAGS="$RUSTFLAGS --cfg fuzzing"          # used to change code logic
RUSTFLAGS="$RUSTFLAGS -Cdebug-assertions"     # to get debug_assert in rust
RUSTFLAGS="$RUSTFLAGS -Zsanitizer=address"    # address sanitizer (ASAN)

RUSTFLAGS="$RUSTFLAGS -Cdebuginfo=1"
RUSTFLAGS="$RUSTFLAGS -Cforce-frame-pointers"

RUSTFLAGS="$RUSTFLAGS -Cpasses=sancov"
RUSTFLAGS="$RUSTFLAGS -Cllvm-args=-sanitizer-coverage-level=4"
RUSTFLAGS="$RUSTFLAGS -Cllvm-args=-sanitizer-coverage-trace-compares"
RUSTFLAGS="$RUSTFLAGS -Cllvm-args=-sanitizer-coverage-inline-8bit-counters"
RUSTFLAGS="$RUSTFLAGS -Cllvm-args=-sanitizer-coverage-trace-geps"
RUSTFLAGS="$RUSTFLAGS -Cllvm-args=-sanitizer-coverage-prune-blocks=0"
RUSTFLAGS="$RUSTFLAGS -Cllvm-args=-sanitizer-coverage-pc-table"
RUSTFLAGS="$RUSTFLAGS -Clink-dead-code"
RUSTFLAGS="$RUSTFLAGS -Cllvm-args=-sanitizer-coverage-stack-depth"
RUSTFLAGS="$RUSTFLAGS -Ccodegen-units=1"

export RUSTFLAGS
export SINGLE_FUZZ_TARGET=from_slice
cargo build --manifest-path fuzz/Cargo.toml --bin from_slice --release --target x86_64-unknown-linux-gnu 
mv $SRC/json/fuzz/target/x86_64-unknown-linux-gnu/release/from_slice $OUT/$SINGLE_FUZZ_TARGET
rm -rf $SRC/json/fuzz/target

cd $SRC/json/
#RUSTFLAGS="-C link-arg=-L/usr/local/lib -C link-arg=-lc++ --cfg fuzzing -Cdebug-assertions -Zsanitizer=address -Cdebuginfo=1 -Cforce-frame-pointers -Cpasses=sancov -Cllvm-args=-sanitizer-coverage-level=4 -Cllvm-args=-sanitizer-coverage-trace-compares -Cllvm-args=-sanitizer-coverage-trace-geps -Cllvm-args=-sanitizer-coverage-pc-table -Cllvm-args=-sanitizer-coverage-stack-depth -Clink-dead-code -Ccodegen-units=1 --emit=llvm-bc" cargo build --manifest-path fuzz/Cargo.toml --bin from_slice --release --target x86_64-unknown-linux-gnu
#export CFLAGS="-O1 -fno-omit-frame-pointer -gline-tables-only -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION"
#export CXXFLAGS_EXTRA="-stdlib=libc++"
RUSTFLAGS="-C link-arg=-L/usr/local/lib -C link-arg=-lc++ --cfg fuzzing -Cdebug-assertions -Cdebuginfo=1 -Cforce-frame-pointers -Cpasses=sancov -Clink-dead-code -Ccodegen-units=1 --emit=llvm-bc" cargo build --manifest-path fuzz/Cargo.toml --bin from_slice --release --target x86_64-unknown-linux-gnu

cd $SRC/json/fuzz/target/x86_64-unknown-linux-gnu/release/deps/
llvm-link ./*.bc -o from_slice.bc
cp $SRC/1.47-nightly ./
llvm-link 1.47-nightly.bc from_slice.bc -o from_slice.bc 
llvm-dis from_slice.bc
#sed -i 's/call i8\* @__rust_alloc/call i8\* @__rdl_alloc/g' from_slice.ll
#sed -i 's/dereferenceable_or_null(4) i8\* @__rust_alloc/dereferenceable_or_null(4) i8\* @__rdl_alloc/g' from_slice.ll
sed -i 's/__rust_alloc/rdl_alloc/g' from_slice.ll
sed -i 's/declare i8\* @__rdl_alloc/declare i8\* @__rust_alloc/g' from_slice.ll
sed -i 's/declare noalias i8\* @__rdl_alloc/declare noalias i8\* @__rust_alloc/g' from_slice.ll
sed -i 's/call i8\* @__rust_realloc/call i8\* @__rdl_realloc/g' from_slice.ll
sed -i 's/call void @__rust_dealloc/call void @__rdl_dealloc/g' from_slice.ll
mv $SRC/json/fuzz/target/x86_64-unknown-linux-gnu/release/deps/from_slice.bc $OUT/
