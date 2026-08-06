fn main() {
    xdr_codegen::Compiler::new()
        .disable_debug_for("FileHandle".to_string())
        .disable_debug_for("FileAttributes".to_string())
        .disable_debug_for("CookieVerf".to_string())
        .disable_debug_for("ReadResOk".to_string())
        .file("mount_proto.x")
        .file("nfs3_xdr.x")
        .enable_derive_serialize()
        .run()
        .expect("That should have worked. :(");
}
