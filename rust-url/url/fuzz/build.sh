sed -i 's/__rust_alloc/__rdl_alloc/g' parse.ll
#sed -i 's/dereferenceable_or_null(4) i8\* @__rust_alloc/dereferenceable_or_null(4) i8\* @__rdl_alloc/g' from_slice.ll
sed -i 's/declare i8\* @__rdl_alloc/declare i8\* @__rust_alloc/g' parse.ll
sed -i 's/declare noalias i8\* @__rdl_alloc/declare noalias i8\* @__rust_alloc/g' parse.ll
sed -i 's/__rust_realloc/__rdl_realloc/g' parse.ll
sed -i 's/declare i8\* @__rdl_realloc/declare i8\* @__rust_realloc/g' parse.ll
sed -i 's/declare noalias i8\* @__rdl_realloc/declare noalias i8\* @__rust_realloc/g' parse.ll
sed -i 's/call void @__rust_dealloc/call void @__rdl_dealloc/g' parse.ll

