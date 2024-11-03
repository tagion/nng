module nngd.mime;
const string[string] nng_mime_map = [
 ".bin": "application/octet-stream"
,".A2L": "application/A2L"
,".a2l": "application/a2l"
,".activemessage": "application/activemessage"
,".AML": "application/AML"
,".aml": "application/aml"
,".applefile": "application/applefile"
,".ATF": "application/ATF"
,".atf": "application/atf"
,".ATFX": "application/ATFX"
,".atfx": "application/atfx"
,".atomicmail": "application/atomicmail"
,".ATXML": "application/ATXML"
,".atxml": "application/atxml"
,".bufr": "application/bufr"
,".c2pa": "application/c2pa"
,".cbor": "application/cbor"
,".cccex": "application/cccex"
,".cdni": "application/cdni"
,".CEA": "application/CEA"
,".cea": "application/cea"
,".cfw": "application/cfw"
,".clr": "application/clr"
,".cms": "application/cms"
,".commonground": "application/commonground"
,".cose": "application/cose"
,".csrattrs": "application/csrattrs"
,".cwl": "application/cwl"
,".cwt": "application/cwt"
,".cybercash": "application/cybercash"
,".dashdelta": "application/dashdelta"
,".DCD": "application/DCD"
,".dcd": "application/dcd"
,".dicom": "application/dicom"
,".DII": "application/DII"
,".dii": "application/dii"
,".DIT": "application/DIT"
,".dit": "application/dit"
,".dns": "application/dns"
,".dvcs": "application/dvcs"
,".EDIFACT": "application/EDIFACT"
,".edifact": "application/edifact"
,".efi": "application/efi"
,".encaprtp": "application/encaprtp"
,".eshop": "application/eshop"
,".example": "application/example"
,".exi": "application/exi"
,".express": "application/express"
,".fastinfoset": "application/fastinfoset"
,".fastsoap": "application/fastsoap"
,".fdf": "application/fdf"
,".fits": "application/fits"
,".flexfec": "application/flexfec"
,".grib": "application/grib"
,".gzip": "application/gzip"
,".H224": "application/H224"
,".h224": "application/h224"
,".http": "application/http"
,".hyperstudio": "application/hyperstudio"
,".iges": "application/iges"
,".index": "application/index"
,".IOTP": "application/IOTP"
,".iotp": "application/iotp"
,".ipfix": "application/ipfix"
,".ipp": "application/ipp"
,".ISUP": "application/ISUP"
,".isup": "application/isup"
,".jose": "application/jose"
,".json": "application/json"
,".jsonpath": "application/jsonpath"
,".jwt": "application/jwt"
,".linkset": "application/linkset"
,".LXF": "application/LXF"
,".lxf": "application/lxf"
,".macwriteii": "application/macwriteii"
,".marc": "application/marc"
,".mathematica": "application/mathematica"
,".mbox": "application/mbox"
,".MF4": "application/MF4"
,".mf4": "application/mf4"
,".mikey": "application/mikey"
,".mipc": "application/mipc"
,".mp21": "application/mp21"
,".mp4": "application/mp4"
,".msword": "application/msword"
,".mxf": "application/mxf"
,".nasdata": "application/nasdata"
,".node": "application/node"
,".nss": "application/nss"
,".ODA": "application/ODA"
,".oda": "application/oda"
,".ODX": "application/ODX"
,".odx": "application/odx"
,".ogg": "application/ogg"
,".oscore": "application/oscore"
,".oxps": "application/oxps"
,".p21": "application/p21"
,".parityfec": "application/parityfec"
,".passport": "application/passport"
,".pdf": "application/pdf"
,".PDX": "application/PDX"
,".pdx": "application/pdx"
,".pkcs10": "application/pkcs10"
,".pkcs8": "application/pkcs8"
,".pkcs12": "application/pkcs12"
,".pkixcmp": "application/pkixcmp"
,".postscript": "application/postscript"
,".QSIG": "application/QSIG"
,".qsig": "application/qsig"
,".raptorfec": "application/raptorfec"
,".riscos": "application/riscos"
,".rtf": "application/rtf"
,".rtploopback": "application/rtploopback"
,".rtx": "application/rtx"
,".sbe": "application/sbe"
,".sdp": "application/sdp"
,".SGML": "application/SGML"
,".sgml": "application/sgml"
,".sieve": "application/sieve"
,".simpleSymbolContainer": "application/simpleSymbolContainer"
,".simplesymbolcontainer": "application/simplesymbolcontainer"
,".sipc": "application/sipc"
,".slate": "application/slate"
,".smpte336m": "application/smpte336m"
,".sql": "application/sql"
,".srgs": "application/srgs"
,".sslkeylogfile": "application/sslkeylogfile"
,".stratum": "application/stratum"
,".tnauthlist": "application/tnauthlist"
,".toml": "application/toml"
,".trig": "application/trig"
,".tzif": "application/tzif"
,".ulpfec": "application/ulpfec"
,".vc": "application/vc"
,".vemmi": "application/vemmi"
,".vp": "application/vp"
,".wasm": "application/wasm"
,".widget": "application/widget"
,".wita": "application/wita"
,".xfdf": "application/xfdf"
,".xml": "application/xml"
,".yaml": "application/yaml"
,".yang": "application/yang"
,".zip": "application/zip"
,".zlib": "application/zlib"
,".zstd": "application/zstd"
,".32kadpcm": "audio/32kadpcm"
,".3gpp": "audio/3gpp"
,".3gpp2": "audio/3gpp2"
,".aac": "audio/aac"
,".ac3": "audio/ac3"
,".AMR": "audio/AMR"
,".amr": "audio/amr"
,".aptx": "audio/aptx"
,".asc": "audio/asc"
,".ATRAC3": "audio/ATRAC3"
,".atrac3": "audio/atrac3"
,".basic": "audio/basic"
,".BV16": "audio/BV16"
,".bv16": "audio/bv16"
,".BV32": "audio/BV32"
,".bv32": "audio/bv32"
,".clearmode": "audio/clearmode"
,".CN": "audio/CN"
,".cn": "audio/cn"
,".DAT12": "audio/DAT12"
,".dat12": "audio/dat12"
,".dls": "audio/dls"
,".DV": "audio/DV"
,".dv": "audio/dv"
,".DVI4": "audio/DVI4"
,".dvi4": "audio/dvi4"
,".eac3": "audio/eac3"
,".encaprtp": "audio/encaprtp"
,".EVRC": "audio/EVRC"
,".evrc": "audio/evrc"
,".EVRC0": "audio/EVRC0"
,".evrc0": "audio/evrc0"
,".EVRC1": "audio/EVRC1"
,".evrc1": "audio/evrc1"
,".EVRCB": "audio/EVRCB"
,".evrcb": "audio/evrcb"
,".EVRCB0": "audio/EVRCB0"
,".evrcb0": "audio/evrcb0"
,".EVRCB1": "audio/EVRCB1"
,".evrcb1": "audio/evrcb1"
,".EVRCNW": "audio/EVRCNW"
,".evrcnw": "audio/evrcnw"
,".EVRCNW0": "audio/EVRCNW0"
,".evrcnw0": "audio/evrcnw0"
,".EVRCNW1": "audio/EVRCNW1"
,".evrcnw1": "audio/evrcnw1"
,".EVRCWB": "audio/EVRCWB"
,".evrcwb": "audio/evrcwb"
,".EVRCWB0": "audio/EVRCWB0"
,".evrcwb0": "audio/evrcwb0"
,".EVRCWB1": "audio/EVRCWB1"
,".evrcwb1": "audio/evrcwb1"
,".EVS": "audio/EVS"
,".evs": "audio/evs"
,".example": "audio/example"
,".flac": "audio/flac"
,".flexfec": "audio/flexfec"
,".fwdred": "audio/fwdred"
,".G719": "audio/G719"
,".g719": "audio/g719"
,".G7221": "audio/G7221"
,".g7221": "audio/g7221"
,".G722": "audio/G722"
,".g722": "audio/g722"
,".G723": "audio/G723"
,".g723": "audio/g723"
,".G728": "audio/G728"
,".g728": "audio/g728"
,".G729": "audio/G729"
,".g729": "audio/g729"
,".G7291": "audio/G7291"
,".g7291": "audio/g7291"
,".G729D": "audio/G729D"
,".g729d": "audio/g729d"
,".G729E": "audio/G729E"
,".g729e": "audio/g729e"
,".GSM": "audio/GSM"
,".gsm": "audio/gsm"
,".iLBC": "audio/iLBC"
,".ilbc": "audio/ilbc"
,".L8": "audio/L8"
,".l8": "audio/l8"
,".L16": "audio/L16"
,".l16": "audio/l16"
,".L20": "audio/L20"
,".l20": "audio/l20"
,".L24": "audio/L24"
,".l24": "audio/l24"
,".LPC": "audio/LPC"
,".lpc": "audio/lpc"
,".matroska": "audio/matroska"
,".MELP": "audio/MELP"
,".melp": "audio/melp"
,".MELP600": "audio/MELP600"
,".melp600": "audio/melp600"
,".MELP1200": "audio/MELP1200"
,".melp1200": "audio/melp1200"
,".MELP2400": "audio/MELP2400"
,".melp2400": "audio/melp2400"
,".mhas": "audio/mhas"
,".MPA": "audio/MPA"
,".mpa": "audio/mpa"
,".mp4": "audio/mp4"
,".mpeg": "audio/mpeg"
,".ogg": "audio/ogg"
,".opus": "audio/opus"
,".parityfec": "audio/parityfec"
,".PCMA": "audio/PCMA"
,".pcma": "audio/pcma"
,".PCMU": "audio/PCMU"
,".pcmu": "audio/pcmu"
,".QCELP": "audio/QCELP"
,".qcelp": "audio/qcelp"
,".raptorfec": "audio/raptorfec"
,".RED": "audio/RED"
,".red": "audio/red"
,".rtploopback": "audio/rtploopback"
,".rtx": "audio/rtx"
,".scip": "audio/scip"
,".SMV": "audio/SMV"
,".smv": "audio/smv"
,".SMV0": "audio/SMV0"
,".smv0": "audio/smv0"
,".sofa": "audio/sofa"
,".speex": "audio/speex"
,".t140c": "audio/t140c"
,".t38": "audio/t38"
,".tone": "audio/tone"
,".TSVCIS": "audio/TSVCIS"
,".tsvcis": "audio/tsvcis"
,".UEMCLIP": "audio/UEMCLIP"
,".uemclip": "audio/uemclip"
,".ulpfec": "audio/ulpfec"
,".usac": "audio/usac"
,".VDVI": "audio/VDVI"
,".vdvi": "audio/vdvi"
,".vorbis": "audio/vorbis"
,".collection": "font/collection"
,".otf": "font/otf"
,".sfnt": "font/sfnt"
,".ttf": "font/ttf"
,".woff": "font/woff"
,".woff2": "font/woff2"
,".aces": "image/aces"
,".apng": "image/apng"
,".avci": "image/avci"
,".avcs": "image/avcs"
,".avif": "image/avif"
,".bmp": "image/bmp"
,".cgm": "image/cgm"
,".dpx": "image/dpx"
,".emf": "image/emf"
,".example": "image/example"
,".fits": "image/fits"
,".g3fax": "image/g3fax"
,".gif": "image/gif"
,".heic": "image/heic"
,".heif": "image/heif"
,".hej2k": "image/hej2k"
,".ief": "image/ief"
,".j2c": "image/j2c"
,".jls": "image/jls"
,".jp2": "image/jp2"
,".jpeg": "image/jpeg"
,".jph": "image/jph"
,".jphc": "image/jphc"
,".jpm": "image/jpm"
,".jpx": "image/jpx"
,".jxl": "image/jxl"
,".jxr": "image/jxr"
,".jxrA": "image/jxrA"
,".jxra": "image/jxra"
,".jxrS": "image/jxrS"
,".jxrs": "image/jxrs"
,".jxs": "image/jxs"
,".jxsc": "image/jxsc"
,".jxsi": "image/jxsi"
,".jxss": "image/jxss"
,".ktx": "image/ktx"
,".ktx2": "image/ktx2"
,".naplps": "image/naplps"
,".png": "image/png"
,".t38": "image/t38"
,".tiff": "image/tiff"
,".webp": "image/webp"
,".wmf": "image/wmf"
,".3mf": "model/3mf"
,".e57": "model/e57"
,".example": "model/example"
,".JT": "model/JT"
,".jt": "model/jt"
,".iges": "model/iges"
,".mesh": "model/mesh"
,".mtl": "model/mtl"
,".obj": "model/obj"
,".prc": "model/prc"
,".step": "model/step"
,".stl": "model/stl"
,".u3d": "model/u3d"
,".vrml": "model/vrml"
,".calendar": "text/calendar"
,".cql": "text/cql"
,".css": "text/css"
,".csv": "text/csv"
,".dns": "text/dns"
,".encaprtp": "text/encaprtp"
,".enriched": "text/enriched"
,".example": "text/example"
,".fhirpath": "text/fhirpath"
,".flexfec": "text/flexfec"
,".fwdred": "text/fwdred"
,".gff3": "text/gff3"
,".hl7v2": "text/hl7v2"
,".html": "text/html"
,".javascript": "text/javascript"
,".markdown": "text/markdown"
,".mizar": "text/mizar"
,".n3": "text/n3"
,".parameters": "text/parameters"
,".parityfec": "text/parityfec"
,".plain": "text/plain"
,".raptorfec": "text/raptorfec"
,".RED": "text/RED"
,".red": "text/red"
,".richtext": "text/richtext"
,".rtf": "text/rtf"
,".rtploopback": "text/rtploopback"
,".rtx": "text/rtx"
,".SGML": "text/SGML"
,".sgml": "text/sgml"
,".shaclc": "text/shaclc"
,".shex": "text/shex"
,".spdx": "text/spdx"
,".strings": "text/strings"
,".t140": "text/t140"
,".troff": "text/troff"
,".turtle": "text/turtle"
,".ulpfec": "text/ulpfec"
,".vcard": "text/vcard"
,".vtt": "text/vtt"
,".wgsl": "text/wgsl"
,".xml": "text/xml"
,".3gpp": "video/3gpp"
,".3gpp2": "video/3gpp2"
,".AV1": "video/AV1"
,".av1": "video/av1"
,".BMPEG": "video/BMPEG"
,".bmpeg": "video/bmpeg"
,".BT656": "video/BT656"
,".bt656": "video/bt656"
,".CelB": "video/CelB"
,".celb": "video/celb"
,".DV": "video/DV"
,".dv": "video/dv"
,".encaprtp": "video/encaprtp"
,".evc": "video/evc"
,".example": "video/example"
,".FFV1": "video/FFV1"
,".ffv1": "video/ffv1"
,".flexfec": "video/flexfec"
,".H261": "video/H261"
,".h261": "video/h261"
,".H263": "video/H263"
,".h263": "video/h263"
,".H264": "video/H264"
,".h264": "video/h264"
,".H265": "video/H265"
,".h265": "video/h265"
,".H266": "video/H266"
,".h266": "video/h266"
,".JPEG": "video/JPEG"
,".jpeg": "video/jpeg"
,".jpeg2000": "video/jpeg2000"
,".jxsv": "video/jxsv"
,".matroska": "video/matroska"
,".mj2": "video/mj2"
,".MP1S": "video/MP1S"
,".mp1s": "video/mp1s"
,".MP2P": "video/MP2P"
,".mp2p": "video/mp2p"
,".MP2T": "video/MP2T"
,".mp2t": "video/mp2t"
,".mp4": "video/mp4"
,".MPV": "video/MPV"
,".mpv": "video/mpv"
,".mpeg": "video/mpeg"
,".nv": "video/nv"
,".ogg": "video/ogg"
,".parityfec": "video/parityfec"
,".pointer": "video/pointer"
,".quicktime": "video/quicktime"
,".raptorfec": "video/raptorfec"
,".raw": "video/raw"
,".rtploopback": "video/rtploopback"
,".rtx": "video/rtx"
,".scip": "video/scip"
,".smpte291": "video/smpte291"
,".SMPTE292M": "video/SMPTE292M"
,".smpte292m": "video/smpte292m"
,".ulpfec": "video/ulpfec"
,".vc1": "video/vc1"
,".vc2": "video/vc2"
,".VP8": "video/VP8"
,".vp8": "video/vp8"
,".VP9": "video/VP9"
,".vp9": "video/vp9"
];

