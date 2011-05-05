// ==========================================================
// FreeImage 3
//
// Design and implementation by
// - Floris van den Berg (flvdberg@wxs.nl)
// - Herve Drolon (drolon@infonie.fr)
//
// Contributors:
// - see changes log named 'Whatsnew.txt', see header of each .h and .cpp file
//
// This file is part of FreeImage 3
//
// COVERED CODE IS PROVIDED UNDER THIS LICENSE ON AN "AS IS" BASIS, WITHOUT WARRANTY
// OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT LIMITATION, WARRANTIES
// THAT THE COVERED CODE IS FREE OF DEFECTS, MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE
// OR NON-INFRINGING. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE COVERED
// CODE IS WITH YOU. SHOULD ANY COVERED CODE PROVE DEFECTIVE IN ANY RESPECT, YOU (NOT
// THE INITIAL DEVELOPER OR ANY OTHER CONTRIBUTOR) ASSUME THE COST OF ANY NECESSARY
// SERVICING, REPAIR OR CORRECTION. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL
// PART OF THIS LICENSE. NO USE OF ANY COVERED CODE IS AUTHORIZED HEREUNDER EXCEPT UNDER
// THIS DISCLAIMER.
//
// Use at your own risk!
// ==========================================================
module freeimage.freeimage;

extern(C):
// Version information ------------------------------------------------------

enum FREEIMAGE_MAJOR_VERSION = 3;
enum FREEIMAGE_MINOR_VERSION = 15;
enum FREEIMAGE_RELEASE_SERIAL = 0;

// This really only affects 24 and 32 bit formats, the rest are always RGB order.
version (BigEndian)
  version = FREEIMAGE_COLORORDER_RGB;
else
  version = FREEIMAGE_COLORORDER_BGR;

// Bitmap types -------------------------------------------------------------

struct FIBITMAP { void *data; };
struct FIMULTIBITMAP { void *data; };

// Types used in the library (directly copied from Windows) -----------------

//! TODO: replace with D's seek enum ?
enum SEEK_SET = 0;
enum SEEK_CUR = 1;
enum SEEK_END = 2;

enum : int { FALSE=0, TRUE=1 }
alias int BOOL;
alias ubyte BYTE;
alias ushort WORD;
alias uint DWORD;
alias int LONG;

version(FREEIMAGE_COLORORDER_BGR) {
  struct RGBQUAD {
    BYTE rgbBlue;
    BYTE rgbGreen;
    BYTE rgbRed;
    BYTE rgbReserved;
  };

  struct RGBTRIPLE {
    BYTE rgbtBlue;
    BYTE rgbtGreen;
    BYTE rgbtRed;
  };
} else {
  struct RGBQUAD {
    BYTE rgbtRed;
    BYTE rgbtGreen;
    BYTE rgbtBlue;
    BYTE rgbReserved;
  };

  struct RGBTRIPLE {
    BYTE rgbtRed;
    BYTE rgbtGreen;
    BYTE rgbtBlue;
  };
}

struct BITMAPINFOHEADER {
  DWORD biSize;
  LONG  biWidth;
  LONG  biHeight;
  WORD  biPlanes;
  WORD  biBitCount;
  DWORD biCompression;
  DWORD biSizeImage;
  LONG  biXPelsPerMeter;
  LONG  biYPelsPerMeter;
  DWORD biClrUsed;
  DWORD biClrImportant;
};
alias BITMAPINFOHEADER* PBITMAPINFOHEADER;

struct BITMAPINFO {
  BITMAPINFOHEADER bmiHeader;
  RGBQUAD          bmiColors[1];
};
alias BITMAPINFO* PBITMAPINFO;

// Types used in the library (specific to FreeImage) ------------------------

/** 48-bit RGB
*/
struct FIRGB16 {
  WORD red;
  WORD green;
  WORD blue;
};

/** 64-bit RGBA
*/
struct FIRGBA16 {
  WORD red;
  WORD green;
  WORD blue;
  WORD alpha;
};

/** 96-bit RGB Float
*/
struct FIRGBF {
  float red;
  float green;
  float blue;
};

/** 128-bit RGBA Float
*/
struct FIRGBAF {
  float red;
  float green;
  float blue;
  float alpha;
};

/** Data structure for COMPLEX type (complex number)
*/
struct FICOMPLEX {
  /// real part
  double r;
  /// imaginary part
  double i;
};

// Indexes for byte arrays, masks and shifts for treating pixels as words ---
// These coincide with the order of RGBQUAD and RGBTRIPLE -------------------
/++
#ifndef FREEIMAGE_BIGENDIAN
#if FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR
// Little Endian (x86 / MS Windows, Linux) : BGR(A) order
#define FI_RGBA_RED                             2
#define FI_RGBA_GREEN                   1
#define FI_RGBA_BLUE                    0
#define FI_RGBA_ALPHA                   3
#define FI_RGBA_RED_MASK                0x00FF0000
#define FI_RGBA_GREEN_MASK              0x0000FF00
#define FI_RGBA_BLUE_MASK               0x000000FF
#define FI_RGBA_ALPHA_MASK              0xFF000000
#define FI_RGBA_RED_SHIFT               16
#define FI_RGBA_GREEN_SHIFT             8
#define FI_RGBA_BLUE_SHIFT              0
#define FI_RGBA_ALPHA_SHIFT             24
#else
// Little Endian (x86 / MaxOSX) : RGB(A) order
#define FI_RGBA_RED                             0
#define FI_RGBA_GREEN                   1
#define FI_RGBA_BLUE                    2
#define FI_RGBA_ALPHA                   3
#define FI_RGBA_RED_MASK                0x000000FF
#define FI_RGBA_GREEN_MASK              0x0000FF00
#define FI_RGBA_BLUE_MASK               0x00FF0000
#define FI_RGBA_ALPHA_MASK              0xFF000000
#define FI_RGBA_RED_SHIFT               0
#define FI_RGBA_GREEN_SHIFT             8
#define FI_RGBA_BLUE_SHIFT              16
#define FI_RGBA_ALPHA_SHIFT             24
#endif // FREEIMAGE_COLORORDER
#else
#if FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR
// Big Endian (PPC / none) : BGR(A) order
#define FI_RGBA_RED                             2
#define FI_RGBA_GREEN                   1
#define FI_RGBA_BLUE                    0
#define FI_RGBA_ALPHA                   3
#define FI_RGBA_RED_MASK                0x0000FF00
#define FI_RGBA_GREEN_MASK              0x00FF0000
#define FI_RGBA_BLUE_MASK               0xFF000000
#define FI_RGBA_ALPHA_MASK              0x000000FF
#define FI_RGBA_RED_SHIFT               8
#define FI_RGBA_GREEN_SHIFT             16
#define FI_RGBA_BLUE_SHIFT              24
#define FI_RGBA_ALPHA_SHIFT             0
#else
// Big Endian (PPC / Linux, MaxOSX) : RGB(A) order
#define FI_RGBA_RED                             0
#define FI_RGBA_GREEN                   1
#define FI_RGBA_BLUE                    2
#define FI_RGBA_ALPHA                   3
#define FI_RGBA_RED_MASK                0xFF000000
#define FI_RGBA_GREEN_MASK              0x00FF0000
#define FI_RGBA_BLUE_MASK               0x0000FF00
#define FI_RGBA_ALPHA_MASK              0x000000FF
#define FI_RGBA_RED_SHIFT               24
#define FI_RGBA_GREEN_SHIFT             16
#define FI_RGBA_BLUE_SHIFT              8
#define FI_RGBA_ALPHA_SHIFT             0
#endif // FREEIMAGE_COLORORDER
#endif // FREEIMAGE_BIGENDIAN

#define FI_RGBA_RGB_MASK                (FI_RGBA_RED_MASK|FI_RGBA_GREEN_MASK|FI_RGBA_BLUE_MASK)
+/
// The 16bit macros only include masks and shifts, since each color element is not byte aligned

enum FI16_555 {
  RED_MASK=0x7C00,
  GREEN_MASK= 0x03E0,
  BLUE_MASK = 0x001F,
  RED_SHIFT = 10,
  GREEN_SHIFT = 5,
  BLUE_SHIFT = 0,
}

enum FI16_565 {
  RED_MASK = 0xF800,
  GREEN_MASK = 0x07E0,
  BLUE_MASK = 0x001F,
  RED_SHIFT = 11,
  GREEN_SHIFT = 5,
  BLUE_SHIFT= 0,
}

// ICC profile support ------------------------------------------------------

enum FIICC_DEFAULT = 0x00;
enum FIICC_COLOR_IS_CMYK = 0x01;

struct FIICCPROFILE {
  WORD    flags;  // info flag
  DWORD   size;   // profile's size measured in bytes
  void   *data;   // points to a block of contiguous memory containing the profile
};

// Important enums ----------------------------------------------------------

/** I/O image format identifiers.
*/
enum FREE_IMAGE_FORMAT {
        UNKNOWN = -1,
        BMP         = 0,
        ICO         = 1,
        JPEG        = 2,
        JNG         = 3,
        KOALA       = 4,
        LBM         = 5,
        IFF = LBM,
        MNG         = 6,
        PBM         = 7,
        PBMRAW      = 8,
        PCD         = 9,
        PCX         = 10,
        PGM         = 11,
        PGMRAW      = 12,
        PNG         = 13,
        PPM         = 14,
        PPMRAW      = 15,
        RAS         = 16,
        TARGA       = 17,
        TIFF        = 18,
        WBMP        = 19,
        PSD         = 20,
        CUT         = 21,
        XBM         = 22,
        XPM         = 23,
        DDS         = 24,
        GIF     = 25,
        HDR         = 26,
        FAXG3       = 27,
        SGI         = 28,
        EXR         = 29,
        J2K         = 30,
        JP2         = 31,
        PFM         = 32,
        PICT        = 33,
        RAW         = 34
};

/** Image type used in FreeImage.
*/
 enum FREE_IMAGE_TYPE {
        UNKNOWN = 0,        // unknown type
        BITMAP  = 1,        // standard image                       : 1-, 4-, 8-, 16-, 24-, 32-bit
        UINT16      = 2,    // array of unsigned short      : unsigned 16-bit
        INT16       = 3,    // array of short                       : signed 16-bit
        UINT32      = 4,    // array of unsigned long       : unsigned 32-bit
        INT32       = 5,    // array of long                        : signed 32-bit
        FLOAT       = 6,    // array of float                       : 32-bit IEEE floating point
        DOUBLE      = 7,    // array of double                      : 64-bit IEEE floating point
        COMPLEX     = 8,    // array of FICOMPLEX           : 2 x 64-bit IEEE floating point
        RGB16       = 9,    // 48-bit RGB image                     : 3 x 16-bit
        RGBA16      = 10,   // 64-bit RGBA image            : 4 x 16-bit
        RGBF        = 11,   // 96-bit RGB float image       : 3 x 32-bit IEEE floating point
        RGBAF       = 12    // 128-bit RGBA float image     : 4 x 32-bit IEEE floating point
};

/** Image color type used in FreeImage.
*/
enum FREE_IMAGE_COLOR_TYPE {
        MINISWHITE = 0,             // min value is white
        MINISBLACK = 1,         // min value is black
        RGB        = 2,         // RGB color model
        PALETTE    = 3,         // color map indexed
        RGBALPHA   = 4,             // RGB color model with alpha channel
        CMYK       = 5              // CMYK color model
};

/** Color quantization algorithms.
Constants used in FreeImage_ColorQuantize.
*/
enum FREE_IMAGE_QUANTIZE {
    WUQUANT = 0,            // Xiaolin Wu color quantization algorithm
    NNQUANT = 1                     // NeuQuant neural-net quantization algorithm by Anthony Dekker
};

/** Dithering algorithms.
Constants used in FreeImage_Dither.
*/
enum FREE_IMAGE_DITHER {
    FS                      = 0,    // Floyd & Steinberg error diffusion
    BAYER4x4    = 1,    // Bayer ordered dispersed dot dithering (order 2 dithering matrix)
    BAYER8x8    = 2,    // Bayer ordered dispersed dot dithering (order 3 dithering matrix)
    CLUSTER6x6  = 3,    // Ordered clustered dot dithering (order 3 - 6x6 matrix)
    CLUSTER8x8  = 4,    // Ordered clustered dot dithering (order 4 - 8x8 matrix)
    CLUSTER16x16= 5,    // Ordered clustered dot dithering (order 8 - 16x16 matrix)
    BAYER16x16  = 6             // Bayer ordered dispersed dot dithering (order 4 dithering matrix)
};

/** Lossless JPEG transformations
Constants used in FreeImage_JPEGTransform
*/
enum FREE_IMAGE_JPEG_OPERATION {
        NONE                  = 0,    // no transformation
        FLIP_H                = 1,    // horizontal flip
        FLIP_V                = 2,    // vertical flip
        TRANSPOSE             = 3,    // transpose across UL-to-LR axis
        TRANSVERSE    = 4,    // transpose across UR-to-LL axis
        ROTATE_90             = 5,    // 90-degree clockwise rotation
        ROTATE_180    = 6,    // 180-degree rotation
        ROTATE_270    = 7             // 270-degree clockwise (or 90 ccw)
};

/** Tone mapping operators.
Constants used in FreeImage_ToneMapping.
*/
enum FREE_IMAGE_TMO {
    DRAGO03        = 0,   // Adaptive logarithmic mapping (F. Drago, 2003)
    REINHARD05 = 1,   // Dynamic range reduction inspired by photoreceptor physiology (E. Reinhard, 2005)
    FATTAL02   = 2    // Gradient domain high dynamic range compression (R. Fattal, 2002)
};

/** Upsampling / downsampling filters.
Constants used in FreeImage_Rescale.
*/
enum FREE_IMAGE_FILTER {
        BOX                = 0,  // Box, pulse, Fourier window, 1st order (constant) b-spline
        BICUBIC    = 1,  // Mitchell & Netravali's two-param cubic filter
        BILINEAR   = 2,  // Bilinear filter
        BSPLINE    = 3,  // 4th order (cubic) b-spline
        CATMULLROM = 4,  // Catmull-Rom spline, Overhauser spline
        LANCZOS3   = 5   // Lanczos3 filter
};

/** Color channels.
Constants used in color manipulation routines.
*/
enum FREE_IMAGE_COLOR_CHANNEL {
        RGB        = 0,    // Use red, green and blue channels
        RED        = 1,    // Use red channel
        GREEN      = 2,    // Use green channel
        BLUE       = 3,    // Use blue channel
        ALPHA      = 4,    // Use alpha channel
        BLACK      = 5,    // Use black channel
        REAL       = 6,    // Complex images: use real part
        IMAG       = 7,    // Complex images: use imaginary part
        MAG        = 8,    // Complex images: use magnitude
        PHASE      = 9             // Complex images: use phase
};

// Metadata support ---------------------------------------------------------

/**
  Tag data type information (based on TIFF specifications)

  Note: RATIONALs are the ratio of two 32-bit integer values.
*/
enum FREE_IMAGE_MDTYPE {
        NOTYPE             = 0,    // placeholder
        BYTE               = 1,    // 8-bit unsigned integer
        ASCII              = 2,    // 8-bit bytes w/ last byte null
        SHORT              = 3,    // 16-bit unsigned integer
        LONG               = 4,    // 32-bit unsigned integer
        RATIONAL   = 5,    // 64-bit unsigned fraction
        SBYTE              = 6,    // 8-bit signed integer
        UNDEFINED  = 7,    // 8-bit untyped data
        SSHORT             = 8,    // 16-bit signed integer
        SLONG              = 9,    // 32-bit signed integer
        SRATIONAL  = 10,   // 64-bit signed fraction
        FLOAT              = 11,   // 32-bit IEEE floating point
        DOUBLE             = 12,   // 64-bit IEEE floating point
        IFD                = 13,   // 32-bit unsigned integer (offset)
        PALETTE    = 14    // 32-bit RGBQUAD
};

/**
  Metadata models supported by FreeImage
*/
enum FREE_IMAGE_MDMODEL {
        NODATA                     = -1,
        COMMENTS           = 0,    // single comment or keywords
        EXIF_MAIN          = 1,    // Exif-TIFF metadata
        EXIF_EXIF          = 2,    // Exif-specific metadata
        EXIF_GPS           = 3,    // Exif GPS metadata
        EXIF_MAKERNOTE = 4,        // Exif maker note metadata
        EXIF_INTEROP       = 5,    // Exif interoperability metadata
        IPTC                       = 6,    // IPTC/NAA metadata
        XMP                        = 7,    // Abobe XMP metadata
        GEOTIFF            = 8,    // GeoTIFF metadata
        ANIMATION          = 9,    // Animation metadata
        CUSTOM                     = 10,   // Used to attach other metadata types to a dib
        EXIF_RAW           = 11    // Exif metadata as a raw buffer
};

/**
  Handle to a metadata model
*/
struct FIMETADATA { void *data; };

/**
  Handle to a FreeImage tag
*/
struct FITAG { void *data; };

// File IO routines ---------------------------------------------------------

alias void* fi_handle;
alias uint function(void *buffer, uint size, uint count, fi_handle handle) FI_ReadProc;
alias uint function(void *buffer, uint size, uint count, fi_handle handle) FI_WriteProc;
alias int function(fi_handle handle, long offset, int origin) FI_SeekProc;
// TODO: recheck long ?
alias int function(fi_handle handle) FI_TellProc;

struct FreeImageIO {
  FI_ReadProc  read_proc;     // pointer to the function used to read data
  FI_WriteProc write_proc;    // pointer to the function used to write data
  FI_SeekProc  seek_proc;     // pointer to the function used to seek
  FI_TellProc  tell_proc;     // pointer to the function used to aquire the current position
};

/**
Handle to a memory I/O stream
*/
struct FIMEMORY { void *data; };

// Plugin routines ----------------------------------------------------------

alias const char* function() FI_FormatProc;
alias const char* function() FI_DescriptionProc;
alias const char* function() FI_ExtensionListProc;
alias const char* function() FI_RegExprProc;
alias void* function(FreeImageIO *io, fi_handle handle, BOOL read) FI_OpenProc;
alias void function(FreeImageIO *io, fi_handle handle, void *data) FI_CloseProc;
alias int function(FreeImageIO *io, fi_handle handle, void *data) FI_PageCountProc;
alias int function(FreeImageIO *io, fi_handle handle, void *data) FI_PageCapabilityProc;
alias FIBITMAP* function(FreeImageIO *io, fi_handle handle, int page, int flags, void *data) FI_LoadProc;
alias BOOL function(FreeImageIO *io, FIBITMAP *dib, fi_handle handle, int page, int flags, void *data) FI_SaveProc;
alias BOOL function(FreeImageIO *io, fi_handle handle) FI_ValidateProc;
alias const char* function() FI_MimeProc;
alias BOOL function(int bpp) FI_SupportsExportBPPProc;
alias BOOL function(FREE_IMAGE_TYPE type) FI_SupportsExportTypeProc;
alias BOOL function() FI_SupportsICCProfilesProc;
alias BOOL function() FI_SupportsNoPixelsProc;

struct Plugin {
        FI_FormatProc format_proc;
        FI_DescriptionProc description_proc;
        FI_ExtensionListProc extension_proc;
        FI_RegExprProc regexpr_proc;
        FI_OpenProc open_proc;
        FI_CloseProc close_proc;
        FI_PageCountProc pagecount_proc;
        FI_PageCapabilityProc pagecapability_proc;
        FI_LoadProc load_proc;
        FI_SaveProc save_proc;
        FI_ValidateProc validate_proc;
        FI_MimeProc mime_proc;
        FI_SupportsExportBPPProc supports_export_bpp_proc;
        FI_SupportsExportTypeProc supports_export_type_proc;
        FI_SupportsICCProfilesProc supports_icc_profiles_proc;
        FI_SupportsNoPixelsProc supports_no_pixels_proc;
};

alias void function(Plugin *plugin, int format_id) FI_InitProc;


// Load / Save flag constants -----------------------------------------------

enum FIF_LOAD_NOPIXELS = 0x8000; // loading: load the image header only (not supported by all plugins)

enum BMP_DEFAULT = 0;
enum BMP_SAVE_RLE = 1;
enum CUT_DEFAULT = 0;
enum DDS_DEFAULT = 0;
enum EXR_DEFAULT = 0;               // save data as half with piz-based wavelet compression
enum EXR_FLOAT = 0x0001;  // save data as float instead of as half (not recommended)
enum EXR_NONE = 0x0002;  // save with no compression
enum EXR_ZIP = 0x0004;  // save with zlib compression, in blocks of 16 scan lines
enum EXR_PIZ = 0x0008;  // save with piz-based wavelet compression
enum EXR_PXR24 = 0x0010;  // save with lossy 24-bit float compression
enum EXR_B44 = 0x0020;  // save with lossy 44% float compression - goes to 22% when combined with EXR_LC
enum EXR_LC = 0x0040;  // save images with one luminance and two chroma channels, rather than as RGB (lossy compression)
enum FAXG3_DEFAULT = 0;
enum GIF_DEFAULT = 0;
enum GIF_LOAD256 = 1;               // Load the image as a 256 color image with ununsed palette entries, if it's 16 or 2 color
enum GIF_PLAYBACK = 2;               // 'Play' the GIF to generate each frame (as 32bpp) instead of returning raw frame data when loading
enum HDR_DEFAULT = 0;
enum ICO_DEFAULT = 0;
enum ICO_MAKEALPHA = 1;               // convert to 32bpp and create an alpha channel from the AND-mask when loading
enum IFF_DEFAULT = 0;
enum J2K_DEFAULT = 0;               // save with a 16:1 rate
enum JP2_DEFAULT = 0;               // save with a 16:1 rate
enum JPEG_DEFAULT = 0;           // loading (see JPEG_FAST); saving (see JPEG_QUALITYGOOD|JPEG_SUBSAMPLING_420)
enum JPEG_FAST = 0x0001;      // load the file as fast as possible, sacrificing some quality
enum JPEG_ACCURATE = 0x0002;      // load the file with the best quality, sacrificing some speed
enum JPEG_CMYK = 0x0004;  // load separated CMYK "as is" (use | to combine with other load flags)
enum JPEG_EXIFROTATE = 0x0008;  // load and rotate according to Exif 'Orientation' tag if available
enum JPEG_QUALITYSUPERB = 0x80;        // save with superb quality (100:1)
enum JPEG_QUALITYGOOD = 0x0100;      // save with good quality (75:1)
enum JPEG_QUALITYNORMAL = 0x0200;      // save with normal quality (50:1)
enum JPEG_QUALITYAVERAGE = 0x0400;      // save with average quality (25:1)
enum JPEG_QUALITYBAD = 0x0800;      // save with bad quality (10:1)
enum JPEG_PROGRESSIVE = 0x2000;  // save as a progressive-JPEG (use | to combine with other save flags)
enum JPEG_SUBSAMPLING_411 = 0x1000;             // save with high 4x1 chroma subsampling (4:1:1)
enum JPEG_SUBSAMPLING_420 = 0x4000;             // save with medium 2x2 medium chroma subsampling (4:2:0) - default value
enum JPEG_SUBSAMPLING_422 = 0x8000;             // save with low 2x1 chroma subsampling (4:2:2)
enum JPEG_SUBSAMPLING_444 = 0x10000;    // save with no chroma subsampling (4:4:4)
enum JPEG_OPTIMIZE = 0x20000;         // on saving, compute optimal Huffman coding tables (can reduce a few percent of file size)
enum JPEG_BASELINE = 0x40000;         // save basic JPEG, without metadata or any markers
enum KOALA_DEFAULT = 0;
enum LBM_DEFAULT = 0;
enum MNG_DEFAULT = 0;
enum PCD_DEFAULT = 0;
enum PCD_BASE = 1;           // load the bitmap sized 768 x 512
enum PCD_BASEDIV4 = 2;           // load the bitmap sized 384 x 256
enum PCD_BASEDIV16 = 3;           // load the bitmap sized 192 x 128
enum PCX_DEFAULT = 0;
enum PFM_DEFAULT = 0;
enum PICT_DEFAULT = 0;
enum PNG_DEFAULT = 0;
enum PNG_IGNOREGAMMA = 1;               // loading: avoid gamma correction
enum PNG_Z_BEST_SPEED = 0x0001;  // save using ZLib level 1 compression flag (default value is 6)
enum PNG_Z_DEFAULT_COMPRESSION = 0x0006;  // save using ZLib level 6 compression flag (default recommended value)
enum PNG_Z_BEST_COMPRESSION = 0x0009;  // save using ZLib level 9 compression flag (default value is 6)
enum PNG_Z_NO_COMPRESSION = 0x0100;  // save without ZLib compression
enum PNG_INTERLACED = 0x0200;  // save using Adam7 interlacing (use | to combine with other save flags)
enum PNM_DEFAULT = 0;
enum PNM_SAVE_RAW = 0;       // If set the writer saves in RAW format (i.e. P4, P5 or P6)
enum PNM_SAVE_ASCII = 1;       // If set the writer saves in ASCII format (i.e. P1, P2 or P3)
enum PSD_DEFAULT = 0;
enum PSD_CMYK = 1;               // reads tags for separated CMYK (default is conversion to RGB)
enum PSD_LAB = 2;               // reads tags for CIELab (default is conversion to RGB)
enum RAS_DEFAULT = 0;
enum RAW_DEFAULT = 0;           // load the file as linear RGB 48-bit
enum RAW_PREVIEW = 1;               // try to load the embedded JPEG preview with included Exif Data or default to RGB 24-bit
enum RAW_DISPLAY = 2;               // load the file as RGB 24-bit
enum SGI_DEFAULT = 0;
enum TARGA_DEFAULT = 0;
enum TARGA_LOAD_RGB888 = 1;       // If set the loader converts RGB555 and ARGB8888 -> RGB888.
enum TARGA_SAVE_RLE = 2;               // If set, the writer saves with RLE compression
enum TIFF_DEFAULT = 0;
enum TIFF_CMYK = 0x0001;  // reads/stores tags for separated CMYK (use | to combine with compression flags)
enum TIFF_PACKBITS = 0x0100;  // save using PACKBITS compression
enum TIFF_DEFLATE = 0x0200;  // save using DEFLATE compression (a.k.a. ZLIB compression)
enum TIFF_ADOBE_DEFLATE = 0x0400;  // save using ADOBE DEFLATE compression
enum TIFF_NONE = 0x0800;  // save without any compression
enum TIFF_CCITTFAX3 = 0x1000;  // save using CCITT Group 3 fax encoding
enum TIFF_CCITTFAX4 = 0x2000;  // save using CCITT Group 4 fax encoding
enum TIFF_LZW = 0x4000;  // save using LZW compression
enum TIFF_JPEG = 0x8000;  // save using JPEG compression
enum TIFF_LOGLUV = 0x10000; // save using LogLuv compression
enum WBMP_DEFAULT = 0;
enum XBM_DEFAULT = 0;
enum XPM_DEFAULT = 0;

// Background filling options ---------------------------------------------------------
// Constants used in FreeImage_FillBackground and FreeImage_EnlargeCanvas

enum FI_COLOR_IS_RGB_COLOR = 0x00;    // RGBQUAD color is a RGB color (contains no valid alpha channel)
enum FI_COLOR_IS_RGBA_COLOR = 0x01;    // RGBQUAD color is a RGBA color (contains a valid alpha channel)
enum FI_COLOR_FIND_EQUAL_COLOR = 0x02;    // For palettized images: lookup equal RGB color from palette
enum FI_COLOR_ALPHA_IS_INDEX = 0x04;    // The color's rgbReserved member (alpha) contains the palette index to be used
enum FI_COLOR_PALETTE_SEARCH_MASK = (FI_COLOR_FIND_EQUAL_COLOR | FI_COLOR_ALPHA_IS_INDEX);   // No color lookup is performed


// Init / Error routines ----------------------------------------------------

void FreeImage_Initialise(BOOL load_local_plugins_only = FALSE);
void FreeImage_DeInitialise();

// Version routines ---------------------------------------------------------

const(char)* FreeImage_GetVersion();
const(char)* FreeImage_GetCopyrightMessage();

// Message output functions -------------------------------------------------

alias void function(FREE_IMAGE_FORMAT fif, const(char)* msg) FreeImage_OutputMessageFunction;
alias void function(FREE_IMAGE_FORMAT fif, const(char)* msg) FreeImage_OutputMessageFunctionStdCall;

void FreeImage_SetOutputMessageStdCall(FreeImage_OutputMessageFunctionStdCall omf);
void FreeImage_SetOutputMessage(FreeImage_OutputMessageFunction omf);
void FreeImage_OutputMessageProc(int fif, const(char)* fmt, ...);

// Allocate / Clone / Unload routines ---------------------------------------

FIBITMAP* FreeImage_Allocate(int width, int height, int bpp, uint red_mask = 0, uint green_mask = 0, uint blue_mask = 0);
FIBITMAP* FreeImage_AllocateT(FREE_IMAGE_TYPE type, int width, int height, int bpp = 8, uint red_mask = 0, uint green_mask = 0, uint blue_mask = 0);
FIBITMAP * FreeImage_Clone(FIBITMAP *dib);
void FreeImage_Unload(FIBITMAP *dib);

// Header loading routines
BOOL FreeImage_HasPixels(FIBITMAP *dib);

// Load / Save routines -----------------------------------------------------

FIBITMAP* FreeImage_Load(FREE_IMAGE_FORMAT fif, const(char)* filename, int flags = 0);
FIBITMAP* FreeImage_LoadU(FREE_IMAGE_FORMAT fif, const(wchar)* filename, int flags = 0);
FIBITMAP* FreeImage_LoadFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags = 0);
BOOL FreeImage_Save(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const(char)* filename, int flags = 0);
BOOL FreeImage_SaveU(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const(wchar)* filename, int flags = 0);
BOOL FreeImage_SaveToHandle(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FreeImageIO *io, fi_handle handle, int flags = 0);

// Memory I/O stream routines -----------------------------------------------

FIMEMORY* FreeImage_OpenMemory(BYTE *data = null, DWORD size_in_bytes = 0);
void FreeImage_CloseMemory(FIMEMORY *stream);
FIBITMAP* FreeImage_LoadFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags = 0);
BOOL FreeImage_SaveToMemory(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FIMEMORY *stream, int flags = 0);
long FreeImage_TellMemory(FIMEMORY *stream);
BOOL FreeImage_SeekMemory(FIMEMORY *stream, long offset, int origin);
BOOL FreeImage_AcquireMemory(FIMEMORY *stream, BYTE **data, DWORD *size_in_bytes);
uint FreeImage_ReadMemory(void *buffer, uint size, uint count, FIMEMORY *stream);
uint FreeImage_WriteMemory(const void *buffer, uint size, uint count, FIMEMORY *stream);

FIMULTIBITMAP* FreeImage_LoadMultiBitmapFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags = 0);
BOOL FreeImage_SaveMultiBitmapToMemory(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FIMEMORY *stream, int flags);

// Plugin Interface ---------------------------------------------------------

FREE_IMAGE_FORMAT FreeImage_RegisterLocalPlugin(FI_InitProc proc_address, const(char)* format = null, const(char)* description = null, const(char)* extension = null, const(char)* regexpr = null);
FREE_IMAGE_FORMAT FreeImage_RegisterExternalPlugin(const(char)* path, const(char)* format = null, const(char)* description = null, const(char)* extension = null, const(char)* regexpr = null);
int FreeImage_GetFIFCount();
int FreeImage_SetPluginEnabled(FREE_IMAGE_FORMAT fif, BOOL enable);
int FreeImage_IsPluginEnabled(FREE_IMAGE_FORMAT fif);
FREE_IMAGE_FORMAT FreeImage_GetFIFFromFormat(const(char)* format);
FREE_IMAGE_FORMAT FreeImage_GetFIFFromMime(const(char)* mime);
const(char)* FreeImage_GetFormatFromFIF(FREE_IMAGE_FORMAT fif);
const(char)* FreeImage_GetFIFExtensionList(FREE_IMAGE_FORMAT fif);
const(char)* FreeImage_GetFIFDescription(FREE_IMAGE_FORMAT fif);
const(char)* FreeImage_GetFIFRegExpr(FREE_IMAGE_FORMAT fif);
const(char)* FreeImage_GetFIFMimeType(FREE_IMAGE_FORMAT fif);
FREE_IMAGE_FORMAT FreeImage_GetFIFFromFilename(const(char)* filename);
FREE_IMAGE_FORMAT FreeImage_GetFIFFromFilenameU(const(wchar)* filename);
BOOL FreeImage_FIFSupportsReading(FREE_IMAGE_FORMAT fif);
BOOL FreeImage_FIFSupportsWriting(FREE_IMAGE_FORMAT fif);
BOOL FreeImage_FIFSupportsExportBPP(FREE_IMAGE_FORMAT fif, int bpp);
BOOL FreeImage_FIFSupportsExportType(FREE_IMAGE_FORMAT fif, FREE_IMAGE_TYPE type);
BOOL FreeImage_FIFSupportsICCProfiles(FREE_IMAGE_FORMAT fif);
BOOL FreeImage_FIFSupportsNoPixels(FREE_IMAGE_FORMAT fif);

// Multipaging interface ----------------------------------------------------

FIMULTIBITMAP * FreeImage_OpenMultiBitmap(FREE_IMAGE_FORMAT fif, const(char)* filename, BOOL create_new, BOOL read_only, BOOL keep_cache_in_memory = FALSE, int flags = 0);
FIMULTIBITMAP * FreeImage_OpenMultiBitmapFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags = 0);
BOOL FreeImage_SaveMultiBitmapToHandle(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FreeImageIO *io, fi_handle handle, int flags = 0);
BOOL FreeImage_CloseMultiBitmap(FIMULTIBITMAP *bitmap, int flags = 0);
int FreeImage_GetPageCount(FIMULTIBITMAP *bitmap);
void FreeImage_AppendPage(FIMULTIBITMAP *bitmap, FIBITMAP *data);
void FreeImage_InsertPage(FIMULTIBITMAP *bitmap, int page, FIBITMAP *data);
void FreeImage_DeletePage(FIMULTIBITMAP *bitmap, int page);
FIBITMAP * FreeImage_LockPage(FIMULTIBITMAP *bitmap, int page);
void FreeImage_UnlockPage(FIMULTIBITMAP *bitmap, FIBITMAP *data, BOOL changed);
BOOL FreeImage_MovePage(FIMULTIBITMAP *bitmap, int target, int source);
BOOL FreeImage_GetLockedPageNumbers(FIMULTIBITMAP *bitmap, int *pages, int *count);

// Filetype request routines ------------------------------------------------

FREE_IMAGE_FORMAT FreeImage_GetFileType(const(char)* filename, int size = 0);
FREE_IMAGE_FORMAT FreeImage_GetFileTypeU(const(wchar)* filename, int size = 0);
FREE_IMAGE_FORMAT FreeImage_GetFileTypeFromHandle(FreeImageIO *io, fi_handle handle, int size = 0);
FREE_IMAGE_FORMAT FreeImage_GetFileTypeFromMemory(FIMEMORY *stream, int size = 0);

// Image type request routine -----------------------------------------------

FREE_IMAGE_TYPE FreeImage_GetImageType(FIBITMAP *dib);

// FreeImage helper routines ------------------------------------------------

BOOL FreeImage_IsLittleEndian();
BOOL FreeImage_LookupX11Color(const(char)* szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue);
BOOL FreeImage_LookupSVGColor(const(char)* szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue);

// Pixel access routines ----------------------------------------------------

BYTE* FreeImage_GetBits(FIBITMAP *dib);
BYTE* FreeImage_GetScanLine(FIBITMAP *dib, int scanline);

BOOL FreeImage_GetPixelIndex(FIBITMAP *dib, uint x, uint y, BYTE *value);
BOOL FreeImage_GetPixelColor(FIBITMAP *dib, uint x, uint y, RGBQUAD *value);
BOOL FreeImage_SetPixelIndex(FIBITMAP *dib, uint x, uint y, BYTE *value);
BOOL FreeImage_SetPixelColor(FIBITMAP *dib, uint x, uint y, RGBQUAD *value);

// DIB info routines --------------------------------------------------------

uint FreeImage_GetColorsUsed(FIBITMAP *dib);
uint FreeImage_GetBPP(FIBITMAP *dib);
uint FreeImage_GetWidth(FIBITMAP *dib);
uint FreeImage_GetHeight(FIBITMAP *dib);
uint FreeImage_GetLine(FIBITMAP *dib);
uint FreeImage_GetPitch(FIBITMAP *dib);
uint FreeImage_GetDIBSize(FIBITMAP *dib);
RGBQUAD* FreeImage_GetPalette(FIBITMAP *dib);

uint FreeImage_GetDotsPerMeterX(FIBITMAP *dib);
uint FreeImage_GetDotsPerMeterY(FIBITMAP *dib);
void FreeImage_SetDotsPerMeterX(FIBITMAP *dib, uint res);
void FreeImage_SetDotsPerMeterY(FIBITMAP *dib, uint res);

BITMAPINFOHEADER* FreeImage_GetInfoHeader(FIBITMAP *dib);
BITMAPINFO* FreeImage_GetInfo(FIBITMAP *dib);
FREE_IMAGE_COLOR_TYPE FreeImage_GetColorType(FIBITMAP *dib);

uint FreeImage_GetRedMask(FIBITMAP *dib);
uint FreeImage_GetGreenMask(FIBITMAP *dib);
uint FreeImage_GetBlueMask(FIBITMAP *dib);

uint FreeImage_GetTransparencyCount(FIBITMAP *dib);
BYTE * FreeImage_GetTransparencyTable(FIBITMAP *dib);
void FreeImage_SetTransparent(FIBITMAP *dib, BOOL enabled);
void FreeImage_SetTransparencyTable(FIBITMAP *dib, BYTE *table, int count);
BOOL FreeImage_IsTransparent(FIBITMAP *dib);
void FreeImage_SetTransparentIndex(FIBITMAP *dib, int index);
int FreeImage_GetTransparentIndex(FIBITMAP *dib);

BOOL FreeImage_HasBackgroundColor(FIBITMAP *dib);
BOOL FreeImage_GetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor);
BOOL FreeImage_SetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor);

FIBITMAP* FreeImage_GetThumbnail(FIBITMAP *dib);
BOOL FreeImage_SetThumbnail(FIBITMAP *dib, FIBITMAP *thumbnail);

// ICC profile routines -----------------------------------------------------

FIICCPROFILE* FreeImage_GetICCProfile(FIBITMAP *dib);
FIICCPROFILE* FreeImage_CreateICCProfile(FIBITMAP *dib, void *data, long size);
void FreeImage_DestroyICCProfile(FIBITMAP *dib);

// Line conversion routines -------------------------------------------------

void FreeImage_ConvertLine1To4(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine8To4(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16To4_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To4_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To4(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To4(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To8(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine4To8(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To8_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To8_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To8(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To8(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine4To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine8To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16_565_To16_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To16_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To16_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine4To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine8To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16_555_To16_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To16_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To16_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine4To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine8To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16To24_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To24_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine32To24(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine1To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine4To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine8To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void FreeImage_ConvertLine16To32_555(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine16To32_565(BYTE *target, BYTE *source, int width_in_pixels);
void FreeImage_ConvertLine24To32(BYTE *target, BYTE *source, int width_in_pixels);

// Smart conversion routines ------------------------------------------------

FIBITMAP* FreeImage_ConvertTo4Bits(FIBITMAP *dib);
FIBITMAP* FreeImage_ConvertTo8Bits(FIBITMAP *dib);
FIBITMAP* FreeImage_ConvertToGreyscale(FIBITMAP *dib);
FIBITMAP* FreeImage_ConvertTo16Bits555(FIBITMAP *dib);
FIBITMAP* FreeImage_ConvertTo16Bits565(FIBITMAP *dib);
FIBITMAP* FreeImage_ConvertTo24Bits(FIBITMAP *dib);
FIBITMAP* FreeImage_ConvertTo32Bits(FIBITMAP *dib);
FIBITMAP* FreeImage_ColorQuantize(FIBITMAP *dib, FREE_IMAGE_QUANTIZE quantize);
FIBITMAP* FreeImage_ColorQuantizeEx(FIBITMAP *dib, FREE_IMAGE_QUANTIZE quantize = FREE_IMAGE_QUANTIZE.WUQUANT, int PaletteSize = 256, int ReserveSize = 0, RGBQUAD *ReservePalette = null);
FIBITMAP* FreeImage_Threshold(FIBITMAP *dib, BYTE T);
FIBITMAP* FreeImage_Dither(FIBITMAP *dib, FREE_IMAGE_DITHER algorithm);

FIBITMAP* FreeImage_ConvertFromRawBits(BYTE *bits, int width, int height, int pitch, uint bpp, uint red_mask, uint green_mask, uint blue_mask, BOOL topdown = FALSE);
void FreeImage_ConvertToRawBits(BYTE *bits, FIBITMAP *dib, int pitch, uint bpp, uint red_mask, uint green_mask, uint blue_mask, BOOL topdown = FALSE);

FIBITMAP* FreeImage_ConvertToFloat(FIBITMAP *dib);
FIBITMAP* FreeImage_ConvertToRGBF(FIBITMAP *dib);
FIBITMAP* FreeImage_ConvertToUINT16(FIBITMAP *dib);

FIBITMAP* FreeImage_ConvertToStandardType(FIBITMAP *src, BOOL scale_linear = TRUE);
FIBITMAP* FreeImage_ConvertToType(FIBITMAP *src, FREE_IMAGE_TYPE dst_type, BOOL scale_linear = TRUE);

// tone mapping operators
FIBITMAP* FreeImage_ToneMapping(FIBITMAP *dib, FREE_IMAGE_TMO tmo, double first_param = 0, double second_param = 0);
FIBITMAP* FreeImage_TmoDrago03(FIBITMAP *src, double gamma = 2.2, double exposure = 0);
FIBITMAP* FreeImage_TmoReinhard05(FIBITMAP *src, double intensity = 0, double contrast = 0);
FIBITMAP* FreeImage_TmoReinhard05Ex(FIBITMAP *src, double intensity = 0, double contrast = 0, double adaptation = 1, double color_correction = 0);

FIBITMAP* FreeImage_TmoFattal02(FIBITMAP *src, double color_saturation= 0.5, double attenuation = 0.85);

// ZLib interface -----------------------------------------------------------

DWORD FreeImage_ZLibCompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD FreeImage_ZLibUncompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD FreeImage_ZLibGZip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD FreeImage_ZLibGUnzip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD FreeImage_ZLibCRC32(DWORD crc, BYTE *source, DWORD source_size);

// --------------------------------------------------------------------------
// Metadata routines --------------------------------------------------------
// --------------------------------------------------------------------------

// tag creation / destruction
FITAG* FreeImage_CreateTag();
void FreeImage_DeleteTag(FITAG *tag);
FITAG* FreeImage_CloneTag(FITAG *tag);

// tag getters and setters
const(char)* FreeImage_GetTagKey(FITAG *tag);
const(char)* FreeImage_GetTagDescription(FITAG *tag);
WORD FreeImage_GetTagID(FITAG *tag);
FREE_IMAGE_MDTYPE FreeImage_GetTagType(FITAG *tag);
DWORD FreeImage_GetTagCount(FITAG *tag);
DWORD FreeImage_GetTagLength(FITAG *tag);
const(void)* FreeImage_GetTagValue(FITAG *tag);

BOOL FreeImage_SetTagKey(FITAG *tag, const(char)* key);
BOOL FreeImage_SetTagDescription(FITAG *tag, const(char)* description);
BOOL FreeImage_SetTagID(FITAG *tag, WORD id);
BOOL FreeImage_SetTagType(FITAG *tag, FREE_IMAGE_MDTYPE type);
BOOL FreeImage_SetTagCount(FITAG *tag, DWORD count);
BOOL FreeImage_SetTagLength(FITAG *tag, DWORD length);
BOOL FreeImage_SetTagValue(FITAG *tag, const void *value);

// iterator
FIMETADATA* FreeImage_FindFirstMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, FITAG **tag);
BOOL FreeImage_FindNextMetadata(FIMETADATA *mdhandle, FITAG **tag);
void FreeImage_FindCloseMetadata(FIMETADATA *mdhandle);

// metadata setter and getter
BOOL FreeImage_SetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, const(char)* key, FITAG *tag);
BOOL FreeImage_GetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, const(char)* key, FITAG **tag);

// helpers
uint FreeImage_GetMetadataCount(FREE_IMAGE_MDMODEL model, FIBITMAP *dib);
BOOL FreeImage_CloneMetadata(FIBITMAP *dst, FIBITMAP *src);

// tag to C string conversion
const(char)* FreeImage_TagToString(FREE_IMAGE_MDMODEL model, FITAG *tag, char *Make = null);

// --------------------------------------------------------------------------
// Image manipulation toolkit -----------------------------------------------
// --------------------------------------------------------------------------

// rotation and flipping
/// @deprecated see FreeImage_Rotate
FIBITMAP* FreeImage_RotateClassic(FIBITMAP *dib, double angle);
FIBITMAP* FreeImage_Rotate(FIBITMAP *dib, double angle, const void *bkcolor = null);
FIBITMAP* FreeImage_RotateEx(FIBITMAP *dib, double angle, double x_shift, double y_shift, double x_origin, double y_origin, BOOL use_mask);
BOOL FreeImage_FlipHorizontal(FIBITMAP *dib);
BOOL FreeImage_FlipVertical(FIBITMAP *dib);
BOOL FreeImage_JPEGTransform(const(char)* src_file, const(char)* dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect = FALSE);
BOOL FreeImage_JPEGTransformU(const(wchar)* src_file, const(wchar)* dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect = FALSE);

// upsampling / downsampling
FIBITMAP* FreeImage_Rescale(FIBITMAP *dib, int dst_width, int dst_height, FREE_IMAGE_FILTER filter);
FIBITMAP* FreeImage_MakeThumbnail(FIBITMAP *dib, int max_pixel_size, BOOL convert = TRUE);

// color manipulation routines (point operations)
BOOL FreeImage_AdjustCurve(FIBITMAP *dib, BYTE *LUT, FREE_IMAGE_COLOR_CHANNEL channel);
BOOL FreeImage_AdjustGamma(FIBITMAP *dib, double gamma);
BOOL FreeImage_AdjustBrightness(FIBITMAP *dib, double percentage);
BOOL FreeImage_AdjustContrast(FIBITMAP *dib, double percentage);
BOOL FreeImage_Invert(FIBITMAP *dib);
BOOL FreeImage_GetHistogram(FIBITMAP *dib, DWORD *histo, FREE_IMAGE_COLOR_CHANNEL channel = FREE_IMAGE_COLOR_CHANNEL.BLACK);
int FreeImage_GetAdjustColorsLookupTable(BYTE *LUT, double brightness, double contrast, double gamma, BOOL invert);
BOOL FreeImage_AdjustColors(FIBITMAP *dib, double brightness, double contrast, double gamma, BOOL invert = FALSE);
uint FreeImage_ApplyColorMapping(FIBITMAP *dib, RGBQUAD *srccolors, RGBQUAD *dstcolors, uint count, BOOL ignore_alpha, BOOL swap);
uint FreeImage_SwapColors(FIBITMAP *dib, RGBQUAD *color_a, RGBQUAD *color_b, BOOL ignore_alpha);
uint FreeImage_ApplyPaletteIndexMapping(FIBITMAP *dib, BYTE *srcindices,       BYTE *dstindices, uint count, BOOL swap);
uint FreeImage_SwapPaletteIndices(FIBITMAP *dib, BYTE *index_a, BYTE *index_b);

// channel processing routines
FIBITMAP* FreeImage_GetChannel(FIBITMAP *dib, FREE_IMAGE_COLOR_CHANNEL channel);
BOOL FreeImage_SetChannel(FIBITMAP *dst, FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);
FIBITMAP* FreeImage_GetComplexChannel(FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);
BOOL FreeImage_SetComplexChannel(FIBITMAP *dst, FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);

// copy / paste / composite routines
FIBITMAP* FreeImage_Copy(FIBITMAP *dib, int left, int top, int right, int bottom);
BOOL FreeImage_Paste(FIBITMAP *dst, FIBITMAP *src, int left, int top, int alpha);
FIBITMAP* FreeImage_Composite(FIBITMAP *fg, BOOL useFileBkg = FALSE, RGBQUAD *appBkColor = null, FIBITMAP *bg = null);
BOOL FreeImage_JPEGCrop(const(char)* src_file, const(char)* dst_file, int left, int top, int right, int bottom);
BOOL FreeImage_JPEGCropU(const(wchar)* src_file, const(wchar)* dst_file, int left, int top, int right, int bottom);
BOOL FreeImage_PreMultiplyWithAlpha(FIBITMAP *dib);

// background filling routines
BOOL FreeImage_FillBackground(FIBITMAP *dib, const void *color, int options = 0);
FIBITMAP* FreeImage_EnlargeCanvas(FIBITMAP *src, int left, int top, int right, int bottom, const void *color, int options = 0);
FIBITMAP* FreeImage_AllocateEx(int width, int height, int bpp, const RGBQUAD *color, int options = 0, const RGBQUAD *palette = null, uint red_mask = 0, uint green_mask = 0, uint blue_mask = 0);
FIBITMAP* FreeImage_AllocateExT(FREE_IMAGE_TYPE type, int width, int height, int bpp, const void *color, int options = 0, const RGBQUAD *palette = null, uint red_mask = 0, uint green_mask = 0, uint blue_mask = 0);

// miscellaneous algorithms
FIBITMAP* FreeImage_MultigridPoissonSolver(FIBITMAP *Laplacian, int ncycle = 3);
