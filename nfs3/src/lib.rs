// SPDX-License-Identifier: BSD-3-Clause
// Copyright 2025. Triad National Security, LLC.

use core::fmt;

use clap::{builder::PossibleValue, ValueEnum};

include!(concat!(env!("OUT_DIR"), "/mount_proto.rs"));

include!(concat!(env!("OUT_DIR"), "/nfs3_xdr.rs"));

struct HexDebug<'a>(&'a Vec<u8>);
impl<'a> fmt::Debug for HexDebug<'a> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", &hex::encode(self.0))
    }
}

struct SliceSummary<'a>(&'a Vec<u8>);
impl<'a> fmt::Debug for SliceSummary<'a> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "[..;{}]", self.0.len())
    }
}

impl fmt::Debug for nfs3_xdr::FileHandle {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("FileHandle")
            .field("data", &HexDebug(&self.data))
            .finish()
    }
}

impl fmt::Debug for nfs3_xdr::CookieVerf {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("CookieVerf")
            .field("data", &HexDebug(&Vec::from(self.data)))
            .finish()
    }
}

struct OctalDebug<T>(T);
impl<T: fmt::Octal> fmt::Debug for OctalDebug<T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "0{:o}", self.0)
    }
}

impl fmt::Debug for nfs3_xdr::FileAttributes {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("FileAttributes")
            .field("type", &self.r#type)
            .field("mode", &OctalDebug(self.mode))
            .field("nlink", &self.nlink)
            .field("uid", &self.uid)
            .field("gid", &self.gid)
            .field("size", &self.size)
            .field("used", &self.used)
            .field("rdev", &self.rdev)
            .field("fsid", &self.fsid)
            .field("fileid", &self.fileid)
            .field("atime", &self.atime)
            .field("mtime", &self.mtime)
            .field("ctime", &self.ctime)
            .finish()
    }
}
impl fmt::Debug for nfs3_xdr::ReadResOk {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ReadResOk")
            .field("file_attributes", &self.file_attributes)
            .field("count", &self.count)
            .field("eof", &self.eof)
            .field("data", &SliceSummary(&self.data))
            .finish()
    }
}

impl ValueEnum for nfs3_xdr::StableHow {
    fn value_variants<'a>() -> &'a [Self] {
        &[
            nfs3_xdr::StableHow::UNSTABLE,
            nfs3_xdr::StableHow::DATA_SYNC,
            nfs3_xdr::StableHow::FILE_SYNC,
        ]
    }

    fn to_possible_value(&self) -> Option<PossibleValue> {
        Some(match self {
            Self::UNSTABLE => PossibleValue::new("unstable"),
            Self::DATA_SYNC => PossibleValue::new("datasync"),
            Self::FILE_SYNC => PossibleValue::new("filesync"),
        })
    }
}

impl ValueEnum for nfs3_xdr::FileType {
    fn value_variants<'a>() -> &'a [Self] {
        &[
            Self::Reg,
            Self::Dir,
            Self::Fifo,
            Self::Sock,
            Self::Chr,
            Self::Blk,
            Self::Lnk,
        ]
    }

    fn to_possible_value(&self) -> Option<PossibleValue> {
        Some(match self {
            Self::Reg => PossibleValue::new("Reg"),
            Self::Dir => PossibleValue::new("Dir"),
            Self::Fifo => PossibleValue::new("Fifo"),
            Self::Sock => PossibleValue::new("Sock"),
            Self::Chr => PossibleValue::new("Chr"),
            Self::Blk => PossibleValue::new("Blk"),
            Self::Lnk => PossibleValue::new("Lnk"),
        })
    }
}
