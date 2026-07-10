fn main() {
    xdr_codegen::Compiler::new()
        .file("../../tests/input/optional.x")
        .enable_no_alloc()
        .enable_zcopy()
        .run()
        .expect("That should have worked. :(");
}
