// SPDX-License-Identifier: BSD-3-Clause
// Copyright 2025. Triad National Security, LLC.

use std::{io, net::TcpStream};

use clap::{Args, Parser, Subcommand, ValueEnum};

use ::nfs3::{nfs3_xdr::procedures::*, nfs3_xdr::*};
use rpc_protocol::{client::*, rpc_prot::authsys_parms, OpaqueAuth};

#[derive(ValueEnum, Clone, Debug)]
enum Sec {
    Sys,
    None,
}

#[derive(Args, Debug)]
struct SysSecArgs {
    #[arg(long, default_value_t = 1000)]
    uid: u32,

    #[arg(long, default_value_t = 1000)]
    gid: u32,

    #[arg(long)]
    groups: Vec<u32>,

    #[arg(long, default_value_t = 42)]
    stamp: u32,

    #[arg(long, default_value = "nfs_cli")]
    machine_name: String,
}

#[derive(Debug, Parser)]
struct Cli {
    #[arg(long, default_value = "localhost")]
    hostname: String,

    #[arg(long, default_value_t = 2049)]
    port: u16,

    #[arg(long)]
    sec: Sec,

    #[command(flatten)]
    syssec: SysSecArgs,

    #[clap(subcommand)]
    command: Command,
}

#[derive(Debug, Subcommand)]
enum Command {
    /// Perform a getattr RPC.
    Getattr {
        #[arg(short, long)]
        filehandle: u64,
    },
}

fn main() -> io::Result<()> {
    let args = Cli::parse();
    eprintln!("{args:?}");

    let mut stream = TcpStream::connect(format!("{}:{}", args.hostname, args.port))?;

    let cred = match args.sec {
        Sec::Sys => OpaqueAuth::sys(authsys_parms {
            stamp: args.syssec.stamp,
            machinename: args.syssec.machine_name.into(),
            uid: args.syssec.uid,
            gid: args.syssec.gid,
            gids: vec![args.syssec.gid],
        }),
        Sec::None => OpaqueAuth::none(),
    };

    let verf = OpaqueAuth::none();

    match args.command {
        Command::Getattr { filehandle } => do_getattr(&mut stream, filehandle, cred, verf),
    }
}

fn do_getattr(
    stream: &mut TcpStream,
    fh: u64,
    cred: OpaqueAuth,
    verf: OpaqueAuth,
) -> io::Result<()> {
    let arg = GetAttrArgs {
        object: FileHandle {
            data: Vec::from(fh.to_be_bytes()),
        },
    };

    let arg = arg.serialize_alloc();

    let res = do_rpc_call(
        stream,
        NFS_PROGRAM,
        NFS_V3::VERSION,
        NFS_V3::GETATTR,
        &arg,
        cred,
        verf,
    );

    match res {
        Ok(bytes) => {
            let mut res = GetAttrResult::default();
            res.deserialize(&mut bytes.as_slice()).unwrap();
            eprintln!("Success: {res:?}");
        }
        Err(e) => {
            eprintln!("{e:?}");
        }
    };

    Ok(())
}
