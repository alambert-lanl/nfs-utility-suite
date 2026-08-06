const FHSIZE = 64;
const NFS3_COOKIEVERFSIZE = 8;
const NFS3_CREATEVERFSIZE = 8;
const NFS3_WRITEVERFSIZE = 8;

const ACCESS3_READ    = 0x0001;
const ACCESS3_LOOKUP  = 0x0002;
const ACCESS3_MODIFY  = 0x0004;
const ACCESS3_EXTEND  = 0x0008;
const ACCESS3_DELETE  = 0x0010;
const ACCESS3_EXECUTE = 0x0020;

typedef unsigned hyper uint64;
typedef hyper int64;
typedef unsigned long uint32;
typedef long int32;
typedef uint64 FileId;
typedef uint64 Cookie;
typedef string Filename<>;
typedef string Path<>;
typedef uint32 Uid;
typedef uint32 Gid;
typedef uint64 Size;
typedef uint64 Offset;
typedef uint32 Mode;
typedef uint32 Count;

struct CookieVerf {
    opaque data[NFS3_COOKIEVERFSIZE];
};

struct WriteVerf {
    opaque data[NFS3_WRITEVERFSIZE];
};

struct CreateVerf {
    opaque data[NFS3_CREATEVERFSIZE];
};

enum NfsResult {
	Ok          = 0,
	Perm        = 1,
	NoEnt       = 2,
	Io          = 5,
	Nxio        = 6,
	Acces       = 13,
	Exist       = 17,
	XDev        = 18,
	NoDev       = 19,
	NotDir      = 20,
	IsDir       = 21,
	Inval       = 22,
	FBig        = 27,
	NoSpc       = 28,
	RoFs        = 30,
	MLink       = 31,
	NameTooLong = 63,
	NotEmpty    = 66,
	Dquot       = 69,
	Stale       = 70,
	Remote      = 71,
	BadHandle   = 10001,
	NotSync     = 10002,
	BadCookie   = 10003,
	NotSupp     = 10004,
	TooSmall    = 10005,
	ServerFault = 10006,
	Badtype     = 10007,
	Jukebox     = 10008
};

enum FileType {
	Reg    = 1,
	Dir    = 2,
	Blk    = 3,
	Chr    = 4,
	Lnk    = 5,
	Sock   = 6,
	Fifo   = 7
};

struct SpecData {
	uint32     specdata1;
	uint32     specdata2;
};

struct NfsTime {
	uint32   seconds;
	uint32   nseconds;
};

struct FileAttributes {
	FileType  type;
	Mode      mode;
	uint32    nlink;
	Uid       uid;
	Gid       gid;
	Size      size;
	Size      used;
	SpecData  rdev;
	uint64    fsid;
	FileId    fileid;
	NfsTime   atime;
	NfsTime   mtime;
	NfsTime   ctime;
};

union PostOpAttr switch (bool attributes_follow) {
	case TRUE:
		FileAttributes   attributes;
	case FALSE:
		void;
};

struct FileHandle {
	opaque       data<FHSIZE>;
};

union PostOpFh switch (bool handle_follows) {
case TRUE:
     FileHandle  handle;
case FALSE:
     void;
};

struct DiropArgs {
	FileHandle  dir;
	string      name<>;
};

struct GetAttrArgs {
	FileHandle  object;
};

struct GetAttrSuccess {
	FileAttributes   obj_attributes;
};

union GetAttrResult switch (NfsResult status) {
case Ok:
	GetAttrSuccess  resok;
default:
	void;
};

struct LookupArgs {
	DiropArgs  what;
};

struct LookupResOK {
	FileHandle      object;
	PostOpAttr obj_attributes;
	PostOpAttr dir_attributes;
};

struct LookupResFail {
	PostOpAttr dir_attributes;
};

union LookupResult switch (NfsResult status) {
	case Ok:
		LookupResOK    resok;
	default:
		LookupResFail  resfail;
};

struct ReaddirArgs {
    FileHandle   dir;
    Cookie       cookie;
    CookieVerf   cookieverf;
    Count        count;
};

struct Entry {
    FileId       fileid;
    Filename     name;
    Cookie       cookie;
    Entry        *nextentry;
};

struct Dirlist {
    Entry        *entries;
    bool         eof;
};

struct ReaddirResOK {
    PostOpAttr   dir_attributes;
    CookieVerf   cookieverf;
    Dirlist      reply;
};

struct ReaddirResFail {
    PostOpAttr dir_attributes;
};

union ReaddirResult switch (NfsResult status) {
case Ok:
    ReaddirResOK   resok;
default:
    ReaddirResFail resfail;
};

struct AccessArgs {
    FileHandle  object;
    uint32      access;
};

struct AccessResOk {
    PostOpAttr   obj_attributes;
    uint32         access;
};

struct AccessResFail {
    PostOpAttr   obj_attributes;
};

union AccessResult switch (NfsResult status) {
case Ok:
    AccessResOk   resok;
default:
    AccessResFail resfail;
};


struct ReadlinkArgs {
    FileHandle  symlink;
};

struct ReadlinkResOk {
    PostOpAttr    symlink_attributes;
    Path          data;
};

struct ReadlinkResFail {
    PostOpAttr    symlink_attributes;
};

union ReadlinkResult switch (NfsResult status) {
case Ok:
    ReadlinkResOk   resok;
default:
    ReadlinkResFail resfail;
};

struct ReadArgs {
    FileHandle  file;
    Offset      offset;
    Count       count;
};

struct ReadResOk {
    PostOpAttr   file_attributes;
    Count        count;
    bool         eof;
    opaque       data<>;
};

struct ReadResFail {
    PostOpAttr   file_attributes;
};


union ReadResult switch (NfsResult status) {
case Ok:
    ReadResOk   resok;
default:
    ReadResFail resfail;
};

enum StableHow {
    UNSTABLE  = 0,
    DATA_SYNC = 1,
    FILE_SYNC = 2
};

struct WccAttr {
    Size        size;
    NfsTime     mtime;
    NfsTime     ctime;
};

union PreOpAttr switch (bool attributes_follow) {
case TRUE:
    WccAttr  attributes;
case FALSE:
    void;
};


struct WccData {
    PreOpAttr      before;
    PostOpAttr     after;
};

struct WriteArgs {
    FileHandle  file;
    Offset      offset;
    Count       count;
    StableHow   stable;
    opaque      data<>;
};

struct WriteResOk {
    WccData    file_wcc;
    Count      count;
    StableHow  committed;
    WriteVerf  verf;
};

struct WriteResFail {
    WccData    file_wcc;
};

union WriteResult switch (NfsResult status) {
case Ok:
    WriteResOk    resok;
default:
    WriteResFail  resfail;
};

enum TimeHow {
   DONT_CHANGE        = 0,
   SET_TO_SERVER_TIME = 1,
   SET_TO_CLIENT_TIME = 2
};

union SetMode switch (bool set_it) {
case TRUE:
    Mode    mode;
default:
    void;
};

union SetUid switch (bool set_it) {
case TRUE:
    Uid     uid;
default:
    void;
};

union SetGid switch (bool set_it) {
case TRUE:
    Gid     gid;
default:
    void;
};

union SetSize switch (bool set_it) {
case TRUE:
    Size    size;
default:
    void;
};

union SetAtime switch (TimeHow set_it) {
case SET_TO_CLIENT_TIME:
    NfsTime  atime;
default:
    void;
};

union SetMtime switch (TimeHow set_it) {
case SET_TO_CLIENT_TIME:
    NfsTime  mtime;
default:
    void;
};

struct Sattr {
    SetMode     mode;
    SetUid      uid;
    SetGid      gid;
    SetSize     size;
    SetAtime    atime;
    SetMtime    mtime;
};

enum CreateMode {
    UNCHECKED = 0,
    GUARDED   = 1,
    EXCLUSIVE = 2
};

struct DirOpArgs {
    FileHandle dir;
    Filename   name;
};

union CreateHow switch (CreateMode mode) {
case UNCHECKED:
case GUARDED:
    Sattr        obj_attributes;
case EXCLUSIVE:
    CreateVerf  verf;
};

struct CreateArgs {
    DirOpArgs     where;
    CreateHow     how;
};

struct CreateResOk {
    PostOpFh      obj;
    PostOpAttr    obj_attributes;
    WccData       dir_wcc;
};

struct CreateResFail {
    WccData      dir_wcc;
};

union CreateResult switch (NfsResult status) {
case Ok:
    CreateResOk    resok;
default:
    CreateResFail  resfail;
};

struct MkdirArgs {
     DirOpArgs    where;
     Sattr        attributes;
};
                                           
struct MkdirResOk {
     PostOpFh    obj;
     PostOpAttr  obj_attributes;
     WccData     dir_wcc;
};
                                           
struct MkdirResFail {
     WccData      dir_wcc;
};
                                           
union MkdirResult switch (NfsResult status) {
case Ok:
     MkdirResOk   resok;
default:
     MkdirResFail resfail;
};

struct SymlinkData {
     Sattr     symlink_attributes;
     Path      symlink_data;
};
                                             
struct SymlinkArgs {
     DirOpArgs    where;
     SymlinkData  symlink;
};
                                             
struct SymlinkResOk {
     PostOpFh      obj;
     PostOpAttr    obj_attributes;
     WccData       dir_wcc;
};
                                             
struct SymlinkResFail {
     WccData       dir_wcc;
};
                                             
union SymlinkResult switch (NfsResult status) {
case Ok:
     SymlinkResOk   resok;
default:
     SymlinkResFail resfail;
};

struct DeviceData {
     Sattr     dev_attributes;
     SpecData  spec;
};

union MknodData switch (FileType type) {
case Chr:
case Blk:
     DeviceData   device;
case Sock:
case Fifo:
     Sattr        pipe_attributes;
default:
     void;
};

struct MknodArgs {
     DirOpArgs    where;
     MknodData    what;
};

struct MknodResOk {
     PostOpFh    obj;
     PostOpAttr  obj_attributes;
     WccData     dir_wcc;
};

struct MknodResFail {
     WccData     dir_wcc;
};

union MknodResult switch (NfsResult status) {
case Ok:
     MknodResOk   resok;
default:
     MknodResFail resfail;
};

struct RemoveArgs {
     DirOpArgs  object;
};
                                            
struct RemoveResOk {
     WccData    dir_wcc;
};
                                            
struct RemoveResFail {
     WccData    dir_wcc;
};
                                            
union RemoveResult switch (NfsResult status) {
case Ok:
     RemoveResOk   resok;
default:
     RemoveResFail resfail;
};

struct RmdirArgs {
     DirOpArgs  object;
};
                                           
struct RmdirResOk {
     WccData     dir_wcc;
};
                                           
struct RmdirResFail {
     WccData     dir_wcc;
};
                                           
union RmdirResult switch (NfsResult status) {
case Ok:
     RmdirResOk   resok;
default:
     RmdirResFail resfail;
};

struct RenameArgs {
     DirOpArgs   from;
     DirOpArgs   to;
};
                                            
struct RenameResOk {
     WccData    fromdir_wcc;
     WccData    todir_wcc;
};
                                            
struct RenameResFail {
     WccData    fromdir_wcc;
     WccData    todir_wcc;
};
                                            
union RenameResult switch (NfsResult status) {
case Ok:
     RenameResOk   resok;
default:
     RenameResFail resfail;
};

struct LinkArgs {
     FileHandle  file;
     DirOpArgs   link;
};
                                          
struct LinkResOk {
     PostOpAttr    file_attributes;
     WccData       linkdir_wcc;
};
                                          
struct LinkResFail {
     PostOpAttr     file_attributes;
     WccData        linkdir_wcc;
};
                                          
union LinkResult switch (NfsResult status) {
case Ok:
     LinkResOk    resok;
default:
     LinkResFail  resfail;
};

struct ReaddirPlusArgs {
     FileHandle  dir;
     Cookie      cookie;
     CookieVerf  cookieverf;
     Count       dircount;
     Count       maxcount;
};
                                   
struct EntryPlus {
     FileId      fileid;
     Filename    name;
     Cookie      cookie;
     PostOpAttr  name_attributes;
     PostOpFh    name_handle;
     EntryPlus   *nextentry;
};
                                   
struct DirlistPlus {
     EntryPlus   *entries;
     bool        eof;
};
                                   
struct ReaddirPlusResOk {
     PostOpAttr  dir_attributes;
     Cookie      cookieverf;
     DirlistPlus reply;
};

struct ReaddirPlusResFail {
     PostOpAttr dir_attributes;
};
                                                 
union ReaddirPlusResult switch (NfsResult status) {
case Ok:
     ReaddirPlusResOk   resok;
default:
     ReaddirPlusResFail resfail;
};

struct FsStatArgs {
     FileHandle   fsroot;
};
                                            
struct FsStatResOk {
     PostOpAttr obj_attributes;
     Size         tbytes;
     Size         fbytes;
     Size         abytes;
     Size         tfiles;
     Size         ffiles;
     Size         afiles;
     uint32       invarsec;
};
                                            
struct FsStatResFail {
     PostOpAttr obj_attributes;
};
                                            
union FsStatResult switch (NfsResult status) {
case Ok:
     FsStatResOk   resok;
default:
     FsStatResFail resfail;
};

const FSF3_LINK        = 0x0001;
const FSF3_SYMLINK     = 0x0002;
const FSF3_HOMOGENEOUS = 0x0008;
const FSF3_CANSETTIME  = 0x0010;
                                  
struct FsInfoArgs {
     FileHandle   fsroot;
};
                                  
struct FsInfoResOk {
     PostOpAttr obj_attributes;
     uint32       rtmax;
     uint32       rtpref;
     uint32       rtmult;
     uint32       wtmax;
     uint32       wtpref;
     uint32       wtmult;
     uint32       dtpref;
     Size         maxfilesize;
     NfsTime      time_delta;
     uint32       properties;
};

struct FsInfoResFail {
     PostOpAttr obj_attributes;
};

union FsInfoResult switch (NfsResult status) {
case Ok:
     FsInfoResOk   resok;
default:
     FsInfoResFail resfail;
};

struct PathconfArgs {
     FileHandle   object;
};
                                              
struct PathconfResOk {
     PostOpAttr obj_attributes;
     uint32       linkmax;
     uint32       name_max;
     bool         no_trunc;
     bool         chown_restricted;
     bool         case_insensitive;
     bool         case_preserving;
};
                                              
struct PathconfResFail {
     PostOpAttr obj_attributes;
};
                                              
union PathconfResult switch (NfsResult status) {
case Ok:
     PathconfResOk   resok;
default:
     PathconfResFail resfail;
};

struct CommitArgs {
     FileHandle    file;
     Offset        offset;
     Count         count;
};
                                            
struct CommitResOk {
     WccData   file_wcc;
     WriteVerf verf;
};
                                            
struct CommitResFail {
     WccData   file_wcc;
};
                                            
union CommitResult switch (NfsResult status) {
case Ok:
     CommitResOk   resok;
default:
     CommitResFail resfail;
};

union SattrGuard switch (bool check) {
case TRUE:
   NfsTime  obj_ctime;
case FALSE:
   void;
};
                                        
struct SattrArgs {
   FileHandle      object;
   Sattr           new_attributes;
   SattrGuard      guard;
};
                                        
struct SattrResOk {
   WccData  obj_wcc;
};
                                        
struct SattrResFail {
   WccData  obj_wcc;
};

union SattrResult switch (NfsResult status) {
case Ok:
   SattrResOk   resok;
default:
   SattrResFail resfail;
};

program NFS_PROGRAM {
	version NFS_V3 {
		void NULL(void)                             = 0;
		GetAttrResult  GETATTR(GetAttrArgs)         = 1;
        SattrRes       SETATTR(SattrArgs)           = 2;
        LookupResult   LOOKUP(LookupArgs)           = 3;
        AccessResult   ACCESS(AccessArgs)           = 4;
        ReadlinkResult READLINK(ReadlinkArgs)       = 5;
        ReadResult     READ(ReadArgs)               = 6;
        WriteResult    WRITE(WriteArgs)             = 7;
        CreateResult   CREATE(CreateArgs)           = 8;
        MkdirResult    MKDIR(MkdirArgs)             = 9;
        SymlinkResult  SYMLINK(SymlinkArgs)         = 10;
        MknodResult    MKNOD(MknodArgs)             = 11;
        RemoveResult   REMOVE(RemoveArgs)           = 12;
        RmdirResult    RMDIR(RmdirArgs)             = 13;
        RenameResult   RENAME(RenameArgs)           = 14;
        LinkResult     LINK(LinkArgs)               = 15;
        ReaddirResult  READDIR(ReaddirArgs)         = 16;
        ReaddirPlusRes READDIRPLUS(ReaddirPlusArgs) = 17;
        FsStatResult   FSSTAT(FsStatArgs)           = 18;
        FsInfoResult   FSINFO(FsInfoArgs)           = 19;
        PathconfResult PATHCONF(PathconfArgs)       = 20;
        CommitResult   COMMIT(CommitArgs)           = 21;
	} = 3;
} = 100003;
