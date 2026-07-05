fn main() {
    xdr_codegen::Compiler::new()
        .file("../../tests/input/optional.x")
        .enable_zcopy()
        .run()
        .expect("That should have worked. :(");
}
