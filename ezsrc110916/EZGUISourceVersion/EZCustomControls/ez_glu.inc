' Copyright (c) 2007 The Khronos Group Inc.

' Permission is hereby granted, free of charge, to any person obtaining a
' copy of this software and/or associated documentation files (the
' "Materials"), to deal in the Materials without restriction, including
' without limitation the rights to use, copy, modify, merge, publish,
' distribute, sublicense, and/or sell copies of the Materials, and to
' permit persons to whom the Materials are furnished to do so, subject to
' the following conditions:

' The above copyright notice and this permission notice shall be included
' in all copies or substantial portions of the Materials.

' THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
' EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
' MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
' IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
' CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
' TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
' MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.
#IF %DEF(%EZ_USEPB90)
     %DefineWGLCalls =   0
#ELSE
     %DefineWGLCalls =   1       ' include Windows OpenGL Extensions (wgl functions)
#ENDIF

' ---------------------------------------------------
' Conversion to Powerbasic by Chris Boss June, 2010
' ---------------------------------------------------
' OpenGL data types:
' ------------------
' GLboolean     is BYTE (character)
' GLbyte        is BYTE (character)
' GLubyte       is BYTE (character)
' GLenum        is DWORD
' GLbitfield    is DWORD
' GLuint        is DWORD
' GLint         is LONG
' GLsizei       is LONG
' GLshort       is INTEGER
' GLushort      is WORD
' GLfloat       is SINGLE
' GLclampf      is SINGLE
' GLdouble      is DOUBLE
' GLclampd      is DOUBLE
' GLvoid        not a type but means a subroutine (VOID no return value)
' ---------------------------------------------------

' ---------------------------------------------------
' OpenGL Constants
' ---------------------------------------------------



' ==========================================================================
' The following are taken from the SPECs documents from OpenGL.ORG web site:
' A few glu items were taken from glu.h header with MS SDK
' ==========================================================================
%GL_VERTEX_ARRAY                = &H00008074
%GL_NORMAL_ARRAY                = &H00008075
%GL_COLOR_ARRAY                 = &H00008076
%GL_INDEX_ARRAY                 = &H00008077
%GL_TEXTURE_COORD_ARRAY         = &H00008078
%GL_EDGE_FLAG_ARRAY             = &H00008079
' --------------------------------------
%GL_POINT                       = &H00001B00
%GL_LINE                        = &H00001B01
%GL_FILL                        = &H00001B02
' --------------------------------------
%GL_FLAT                        =  &H00001D00
%GL_SMOOTH                      =  &H00001D01
%GL_TRUE                        = 1&
%GL_FALSE                       = 0&
' --------------------------------------
' from glu.h header
%GLU_SMOOTH                     = 100000&
%GLU_FLAT                       = 100001&
%GLU_NONE                       = 100002&
%GLU_POINT                      = 100010&
%GLU_LINE                       = 100011&
%GLU_FILL                       = 100012&
%GLU_SILHOUETTE                 = 100013&
%GLU_OUTSIDE                    = 100020&
%GLU_INSIDE                     = 100021&
' --------------------------------------
%GL_ZERO                        = 0&
%GL_ONE                         = 1&
%GL_SRC_COLOR                   = &H00000300
%GL_ONE_MINUS_SRC_COLOR         = &H00000301
%GL_SRC_ALPHA                   = &H00000302
%GL_ONE_MINUS_SRC_ALPHA         = &H00000303
%GL_DST_ALPHA                   = &H00000304
%GL_ONE_MINUS_DST_ALPHA         = &H00000305
' --------------------------------------
%GL_CW                          = &H00000900
%GL_CCW                         = &H00000901
' --------------------------------------
%GL_COMPILE                     = &H00001300
%GL_COMPILE_AND_EXECUTE         = &H00001301
' --------------------------------------
%GL_POINTS                      = &H00000000
%GL_LINES                       = &H00000001
%GL_LINE_LOOP                   = &H00000002
%GL_LINE_STRIP                  = &H00000003
%GL_TRIANGLES                   = &H00000004
%GL_TRIANGLE_STRIP              = &H00000005
%GL_TRIANGLE_FAN                = &H00000006
%GL_QUADS                       = &H00000007
%GL_QUAD_STRIP                  = &H00000008
%GL_POLYGON                     = &H00000009
' --------------------------------------
%GL_VENDOR                      = &H00001F00
%GL_RENDERER                    = &H00001F01
%GL_VERSION                     = &H00001F02
%GL_EXTENSIONS                  = &H00001F03
' --------------------------------------
%GL_MODELVIEW                   = &H00001700
%GL_PROJECTION                  = &H00001701
%GL_TEXTURE                     = &H00001702
' --------------------------------------
%GL_NONE                        = &H00000000
%GL_FRONT_LEFT                  = &H00000400
%GL_FRONT_RIGHT                 = &H00000401
%GL_BACK_LEFT                   = &H00000402
%GL_BACK_RIGHT                  = &H00000403
%GL_FRONT                       = &H00000404
%GL_BACK                        = &H00000405
%GL_LEFT                        = &H00000406
%GL_RIGHT                       = &H00000407
%GL_FRONT_AND_BACK              = &H00000408
%GL_AUX0                        = &H00000409
%GL_AUX1                        = &H0000040A
%GL_AUX2                        = &H0000040B
%GL_AUX3                        = &H0000040C
' --------------------------------------
%GL_BGR                         = &H000080E0
%GL_BGRA                        = &H000080E1
%GL_BGR_EXT                     = &H000080E0
%GL_BGRA_EXT                    = &H000080E1
%GL_ABGR                        = &H00008000
%GL_ABGR_EXT                    = &H00008000

%GL_COLOR_INDEX                     = &H00001900
%GL_STENCIL_INDEX                   = &H00001901
%GL_DEPTH_COMPONENT                 = &H00001902
%GL_RED                             = &H00001903
%GL_GREEN                           = &H00001904
%GL_BLUE                            = &H00001905
%GL_ALPHA                           = &H00001906
%GL_RGB                             = &H00001907
%GL_RGBA                            = &H00001908
%GL_LUMINANCE                       = &H00001909
%GL_LUMINANCE_ALPHA                 = &H0000190A


' --------------------------------------
%GL_BYTE                        = &H00001400
%GL_UNSIGNED_BYTE               = &H00001401
%GL_SHORT                       = &H00001402
%GL_UNSIGNED_SHORT              = &H00001403
%GL_INT                         = &H00001404
%GL_UNSIGNED_INT                = &H00001405
%GL_FLOAT                       = &H00001406
%GL_2_BYTES                     = &H00001407
%GL_3_BYTES                     = &H00001408
%GL_4_BYTES                     = &H00001409
%GL_DOUBLE                      = &H0000140A
%GL_DOUBLE_EXT                  = &H0000140A
' --------------------------------------
%GL_CURRENT_BIT                 = &H00000001
%GL_POINT_BIT                   = &H00000002
%GL_LINE_BIT                    = &H00000004
%GL_POLYGON_BIT                 = &H00000008
%GL_POLYGON_STIPPLE_BIT         = &H00000010
%GL_PIXEL_MODE_BIT              = &H00000020
%GL_LIGHTING_BIT                = &H00000040
%GL_FOG_BIT                     = &H00000080
%GL_DEPTH_BUFFER_BIT            = &H00000100
%GL_ACCUM_BUFFER_BIT            = &H00000200
%GL_STENCIL_BUFFER_BIT          = &H00000400
%GL_VIEWPORT_BIT                = &H00000800
%GL_TRANSFORM_BIT               = &H00001000
%GL_ENABLE_BIT                  = &H00002000
%GL_COLOR_BUFFER_BIT            = &H00004000
%GL_HINT_BIT                    = &H00008000
%GL_EVAL_BIT                    = &H00010000
%GL_LIST_BIT                    = &H00020000
%GL_TEXTURE_BIT                 = &H00040000
%GL_SCISSOR_BIT                 = &H00080000
%GL_ALL_ATTRIB_BITS             = &HFFFFFFFF
' ------------------------------------------
%GL_CURRENT_COLOR                   = &H00000B00
%GL_CURRENT_INDEX                   = &H00000B01
%GL_CURRENT_NORMAL                  = &H00000B02
%GL_CURRENT_TEXTURE_COORDS          = &H00000B03
%GL_CURRENT_RASTER_COLOR            = &H00000B04
%GL_CURRENT_RASTER_INDEX            = &H00000B05
%GL_CURRENT_RASTER_TEXTURE_COORDS   = &H00000B06
%GL_CURRENT_RASTER_POSITION         = &H00000B07
%GL_CURRENT_RASTER_POSITION_VALID   = &H00000B08
%GL_CURRENT_RASTER_DISTANCE         = &H00000B09
' ------------------------------------------
%GL_POINT_SMOOTH                    = &H00000B10
%GL_POINT_SIZE                      = &H00000B11
%GL_POINT_SIZE_RANGE                = &H00000B12
%GL_POINT_SIZE_GRANULARITY          = &H00000B13
' ------------------------------------------
%GL_LINE_SMOOTH                     = &H00000B20
%GL_LINE_WIDTH                      = &H00000B21
%GL_LINE_WIDTH_RANGE                = &H00000B22
%GL_LINE_WIDTH_GRANULARITY          = &H00000B23
%GL_LINE_STIPPLE                    = &H00000B24
%GL_LINE_STIPPLE_PATTERN            = &H00000B25
%GL_LINE_STIPPLE_REPEAT             = &H00000B26
' ------------------------------------------
%GL_LIST_MODE                       = &H00000B30
%GL_MAX_LIST_NESTING                = &H00000B31
%GL_LIST_BASE                       = &H00000B32
%GL_LIST_INDEX                      = &H00000B33
' ------------------------------------------
%GL_POLYGON_MODE                    = &H00000B40
%GL_POLYGON_SMOOTH                  = &H00000B41
%GL_POLYGON_STIPPLE                 = &H00000B42
%GL_EDGE_FLAG                       = &H00000B43
%GL_CULL_FACE                       = &H00000B44
%GL_CULL_FACE_MODE                  = &H00000B45
%GL_FRONT_FACE                      = &H00000B46
' ------------------------------------------
%GL_LIGHTING                        = &H00000B50
%GL_LIGHT_MODEL_LOCAL_VIEWER        = &H00000B51
%GL_LIGHT_MODEL_TWO_SIDE            = &H00000B52
%GL_LIGHT_MODEL_AMBIENT             = &H00000B53
%GL_SHADE_MODEL                     = &H00000B54
%GL_COLOR_MATERIAL_FACE             = &H00000B55
%GL_COLOR_MATERIAL_PARAMETER        = &H00000B56
%GL_COLOR_MATERIAL                  = &H00000B57
' ------------------------------------------
%GL_LIGHT0                          = &H00004000
%GL_LIGHT1                          = &H00004001
%GL_LIGHT2                          = &H00004002
%GL_LIGHT3                          = &H00004003
%GL_LIGHT4                          = &H00004004
%GL_LIGHT5                          = &H00004005
%GL_LIGHT6                          = &H00004006
%GL_LIGHT7                          = &H00004007
' ------------------------------------------
%GL_FOG                             = &H00000B60
%GL_FOG_INDEX                       = &H00000B61
%GL_FOG_DENSITY                     = &H00000B62
%GL_FOG_START                       = &H00000B63
%GL_FOG_END                         = &H00000B64
%GL_FOG_MODE                        = &H00000B65
%GL_FOG_COLOR                       = &H00000B66
' ------------------------------------------
%GL_DEPTH_RANGE                     = &H00000B70
%GL_DEPTH_TEST                      = &H00000B71
%GL_DEPTH_WRITEMASK                 = &H00000B72
%GL_DEPTH_CLEAR_VALUE               = &H00000B73
%GL_DEPTH_FUNC                      = &H00000B74
' ------------------------------------------
%GL_ACCUM_CLEAR_VALUE               = &H00000B80
' ------------------------------------------
%GL_STENCIL_TEST                    = &H00000B90
%GL_STENCIL_CLEAR_VALUE             = &H00000B91
%GL_STENCIL_FUNC                    = &H00000B92
%GL_STENCIL_VALUE_MASK              = &H00000B93
%GL_STENCIL_FAIL                    = &H00000B94
%GL_STENCIL_PASS_DEPTH_FAIL         = &H00000B95
%GL_STENCIL_PASS_DEPTH_PASS         = &H00000B96
%GL_STENCIL_REF                     = &H00000B97
%GL_STENCIL_WRITEMASK               = &H00000B98
' ------------------------------------------
%GL_MATRIX_MODE                     = &H00000BA0
%GL_NORMALIZE                       = &H00000BA1
%GL_VIEWPORT                        = &H00000BA2
%GL_MODELVIEW_STACK_DEPTH           = &H00000BA3
%GL_PROJECTION_STACK_DEPTH          = &H00000BA4
%GL_TEXTURE_STACK_DEPTH             = &H00000BA5
%GL_MODELVIEW_MATRIX                = &H00000BA6
%GL_PROJECTION_MATRIX               = &H00000BA7
%GL_TEXTURE_MATRIX                  = &H00000BA8
' ------------------------------------------
%GL_ATTRIB_STACK_DEPTH              = &H00000BB0
%GL_CLIENT_ATTRIB_STACK_DEPTH       = &H00000BB1
' ------------------------------------------
%GL_ALPHA_TEST                      = &H00000BC0
%GL_ALPHA_TEST_FUNC                 = &H00000BC1
%GL_ALPHA_TEST_REF                  = &H00000BC2
' ------------------------------------------
%GL_DITHER                          = &H00000BD0
' ------------------------------------------
%GL_BLEND_DST                       = &H00000BE0
%GL_BLEND_SRC                       = &H00000BE1
%GL_BLEND                           = &H00000BE2
' ------------------------------------------
%GL_LOGIC_OP_MODE                   = &H00000BF0
%GL_INDEX_LOGIC_OP                  = &H00000BF1
%GL_LOGIC_OP                        = &H00000BF1
%GL_COLOR_LOGIC_OP                  = &H00000BF2
' ------------------------------------------
%GL_AUX_BUFFERS                     = &H00000C00
%GL_DRAW_BUFFER                     = &H00000C01
%GL_READ_BUFFER                     = &H00000C02
' ------------------------------------------
%GL_SCISSOR_BOX                     = &H00000C10
%GL_SCISSOR_TEST                    = &H00000C11
' ------------------------------------------
%GL_INDEX_CLEAR_VALUE               = &H00000C20
%GL_INDEX_WRITEMASK                 = &H00000C21
%GL_COLOR_CLEAR_VALUE               = &H00000C22
%GL_COLOR_WRITEMASK                 = &H00000C23
' ------------------------------------------
%GL_INDEX_MODE                      = &H00000C30
%GL_RGBA_MODE                       = &H00000C31
%GL_DOUBLEBUFFER                    = &H00000C32
%GL_STEREO                          = &H00000C33
' ------------------------------------------
%GL_RENDER_MODE                     = &H00000C40
' ------------------------------------------
%GL_PERSPECTIVE_CORRECTION_HINT     = &H00000C50
%GL_POINT_SMOOTH_HINT               = &H00000C51
%GL_LINE_SMOOTH_HINT                = &H00000C52
%GL_POLYGON_SMOOTH_HINT             = &H00000C53
%GL_FOG_HINT                        = &H00000C54
' ------------------------------------------
%GL_TEXTURE_GEN_S                   = &H00000C60
%GL_TEXTURE_GEN_T                   = &H00000C61
%GL_TEXTURE_GEN_R                   = &H00000C62
%GL_TEXTURE_GEN_Q                   = &H00000C63
' ------------------------------------------
%GL_PIXEL_MAP_I_TO_I_SIZE           = &H00000CB0
%GL_PIXEL_MAP_S_TO_S_SIZE           = &H00000CB1
%GL_PIXEL_MAP_I_TO_R_SIZE           = &H00000CB2
%GL_PIXEL_MAP_I_TO_G_SIZE           = &H00000CB3
%GL_PIXEL_MAP_I_TO_B_SIZE           = &H00000CB4
%GL_PIXEL_MAP_I_TO_A_SIZE           = &H00000CB5
%GL_PIXEL_MAP_R_TO_R_SIZE           = &H00000CB6
%GL_PIXEL_MAP_G_TO_G_SIZE           = &H00000CB7
%GL_PIXEL_MAP_B_TO_B_SIZE           = &H00000CB8
%GL_PIXEL_MAP_A_TO_A_SIZE           = &H00000CB9
' ------------------------------------------
%GL_UNPACK_SWAP_BYTES               = &H00000CF0
%GL_UNPACK_LSB_FIRST                = &H00000CF1
%GL_UNPACK_ROW_LENGTH               = &H00000CF2
%GL_UNPACK_SKIP_ROWS                = &H00000CF3
%GL_UNPACK_SKIP_PIXELS              = &H00000CF4
%GL_UNPACK_ALIGNMENT                = &H00000CF5
' ------------------------------------------
%GL_PACK_SWAP_BYTES                 = &H00000D00
%GL_PACK_LSB_FIRST                  = &H00000D01
%GL_PACK_ROW_LENGTH                 = &H00000D02
%GL_PACK_SKIP_ROWS                  = &H00000D03
%GL_PACK_SKIP_PIXELS                = &H00000D04
%GL_PACK_ALIGNMENT                  = &H00000D05
' ------------------------------------------
%GL_MAP_COLOR                       = &H00000D10
%GL_MAP_STENCIL                     = &H00000D11
%GL_INDEX_SHIFT                     = &H00000D12
%GL_INDEX_OFFSET                    = &H00000D13
%GL_RED_SCALE                       = &H00000D14
%GL_RED_BIAS                        = &H00000D15
%GL_ZOOM_X                          = &H00000D16
%GL_ZOOM_Y                          = &H00000D17
%GL_GREEN_SCALE                     = &H00000D18
%GL_GREEN_BIAS                      = &H00000D19
%GL_BLUE_SCALE                      = &H00000D1A
%GL_BLUE_BIAS                       = &H00000D1B
%GL_ALPHA_SCALE                     = &H00000D1C
%GL_ALPHA_BIAS                      = &H00000D1D
%GL_DEPTH_SCALE                     = &H00000D1E
%GL_DEPTH_BIAS                      = &H00000D1F
' ------------------------------------------
%GL_MAX_EVAL_ORDER                  = &H00000D30
%GL_MAX_LIGHTS                      = &H00000D31
' ------------------------------------------
%GL_DONT_CARE                       = &H00001100
%GL_FASTEST                         = &H00001101
%GL_NICEST                          = &H00001102
' ------------------------------------------
%GL_PIXEL_MAP_I_TO_I                = &H00000C70
%GL_PIXEL_MAP_S_TO_S                = &H00000C71
%GL_PIXEL_MAP_I_TO_R                = &H00000C72
%GL_PIXEL_MAP_I_TO_G                = &H00000C73
%GL_PIXEL_MAP_I_TO_B                = &H00000C74
%GL_PIXEL_MAP_I_TO_A                = &H00000C75
%GL_PIXEL_MAP_R_TO_R                = &H00000C76
%GL_PIXEL_MAP_G_TO_G                = &H00000C77
%GL_PIXEL_MAP_B_TO_B                = &H00000C78
%GL_PIXEL_MAP_A_TO_A                = &H00000C79
' ------------------------------------------
%GL_AMBIENT                         = &H00001200
%GL_DIFFUSE                         = &H00001201
%GL_SPECULAR                        = &H00001202
%GL_POSITION                        = &H00001203
%GL_SPOT_DIRECTION                  = &H00001204
%GL_SPOT_EXPONENT                   = &H00001205
%GL_SPOT_CUTOFF                     = &H00001206
%GL_CONSTANT_ATTENUATION            = &H00001207
%GL_LINEAR_ATTENUATION              = &H00001208
%GL_QUADRATIC_ATTENUATION           = &H00001209
' ------------------------------------------
%GL_EMISSION                        = &H00001600
%GL_SHININESS                       = &H00001601
%GL_AMBIENT_AND_DIFFUSE             = &H00001602
%GL_COLOR_INDEXES                   = &H00001603
' ------------------------------------------
' from gl.h headers in MS SDK:
%GL_TEXTURE_1D                      = &H00000DE0
%GL_TEXTURE_2D                      = &H00000DE1
%GL_MODULATE                        = &H00002100
%GL_DECAL                           = &H00002101
%GL_REPLACE                         = &H00001E01
%GL_TEXTURE_ENV_MODE                = &H00002200
%GL_TEXTURE_ENV_COLOR               = &H00002201
%GL_TEXTURE_ENV                     = &H00002300
%GL_EYE_LINEAR                      = &H00002400
%GL_OBJECT_LINEAR                   = &H00002401
%GL_SPHERE_MAP                      = &H00002402
%GL_TEXTURE_GEN_MODE                = &H00002500
%GL_OBJECT_PLANE                    = &H00002501
%GL_EYE_PLANE                       = &H00002502
%GL_NEAREST                         = &H00002600
%GL_LINEAR                          = &H00002601
%GL_NEAREST_MIPMAP_NEAREST          = &H00002700
%GL_LINEAR_MIPMAP_NEAREST           = &H00002701
%GL_NEAREST_MIPMAP_LINEAR           = &H00002702
%GL_LINEAR_MIPMAP_LINEAR            = &H00002703
%GL_TEXTURE_MAG_FILTER              = &H00002800
%GL_TEXTURE_MIN_FILTER              = &H00002801
%GL_TEXTURE_WRAP_S                  = &H00002802
%GL_TEXTURE_WRAP_T                  = &H00002803
%GL_CLAMP                           = &H00002900
%GL_REPEAT                          = &H00002901
' ==========================================================================




' ---------------------------------------------------
' OpenGL data types:
' ---------------------------------------------------
' GLboolean     is BYTE (character)
' GLbyte        is BYTE (character)
' GLubyte       is BYTE (character)
' GLenum        is DWORD
' GLbitfield    is DWORD
' GLuint        is DWORD
' GLint         is LONG
' GLsizei       is LONG
' GLshort       is INTEGER
' GLushort      is WORD
' GLfloat       is SINGLE
' GLclampf      is SINGLE
' GLdouble      is DOUBLE
' GLclampd      is DOUBLE
' GLvoid        not a type but means a subroutine (VOID no return value)
' ---------------------------------------------------

' ---------------------------------------------------
' OpenGL gl Declares
' ---------------------------------------------------
' GL Declares
' ============
DECLARE SUB glCallList LIB "OPENGL32.DLL" ALIAS "glCallList" (BYVAL list AS DWORD)
DECLARE SUB glClearColor LIB "OPENGL32.DLL" ALIAS "glClearColor" (BYVAL red AS SINGLE, BYVAL green AS SINGLE, BYVAL blue AS SINGLE, BYVAL alpha AS SINGLE)
DECLARE SUB glClearDepth LIB "OPENGL32.DLL" ALIAS "glClearDepth" (BYVAL depth AS DOUBLE)
DECLARE SUB glEnable LIB "OPENGL32.DLL" ALIAS "glEnable" (BYVAL cap AS DWORD)
DECLARE FUNCTION glIsEnabled LIB "OPENGL32.DLL" ALIAS "glIsEnabled" (BYVAL cap AS DWORD) AS DWORD
DECLARE SUB glDisable LIB "OPENGL32.DLL" ALIAS "glDisable" (BYVAL cap AS DWORD)
DECLARE SUB glHint LIB "OPENGL32.DLL" ALIAS "glHint" (BYVAL t AS DWORD, BYVAL MODE AS DWORD)
DECLARE SUB glViewport LIB "OPENGL32.DLL" ALIAS "glViewport" (BYVAL x AS LONG, BYVAL y AS LONG, BYVAL w AS LONG, BYVAL h AS LONG)
DECLARE SUB glMatrixMode LIB "OPENGL32.DLL" ALIAS "glMatrixMode" (BYVAL MODE AS DWORD)
DECLARE SUB glLoadIdentity LIB "OPENGL32.DLL" ALIAS "glLoadIdentity" ()
DECLARE SUB glMatrixMode LIB "OPENGL32.DLL" ALIAS "glMatrixMode" (BYVAL MODE AS DWORD)
DECLARE SUB glClear LIB "OPENGL32.DLL" ALIAS "glClear" (BYVAL mask AS DWORD)
DECLARE SUB glScalef LIB "OPENGL32.DLL" ALIAS "glScalef" (BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
DECLARE SUB glRotatef LIB "OPENGL32.DLL" ALIAS "glRotatef" (BYVAL angle AS SINGLE, BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
DECLARE SUB glDrawBuffer LIB "OPENGL32.DLL" ALIAS "glDrawBuffer" (BYVAL MODE AS DWORD)
DECLARE SUB glNewList LIB "OPENGL32.DLL" ALIAS "glNewList" (BYVAL list AS DWORD, BYVAL MODE AS DWORD)
DECLARE SUB glEndList LIB "OPENGL32.DLL" ALIAS "glEndList" ()
DECLARE SUB glBegin LIB "OPENGL32.DLL" ALIAS "glBegin" (BYVAL MODE AS DWORD)
DECLARE SUB glEnd LIB "OPENGL32.DLL" ALIAS "glEnd" ()
DECLARE SUB glColor3f LIB "OPENGL32.DLL" ALIAS "glColor3f" (BYVAL r AS SINGLE, BYVAL g AS SINGLE, BYVAL b AS SINGLE)
DECLARE SUB glColor4f LIB "OPENGL32.DLL" ALIAS "glColor4f" (BYVAL r AS SINGLE, BYVAL g AS SINGLE, BYVAL b AS SINGLE, BYVAL alpha AS SINGLE)
DECLARE SUB glVertex3f LIB "OPENGL32.DLL" ALIAS "glVertex3f" (BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
DECLARE SUB glReadBuffer LIB "OPENGL32.DLL" ALIAS "glReadBuffer" (BYVAL MODE AS DWORD)
DECLARE SUB glDrawPixels LIB "OPENGL32.DLL" ALIAS "glDrawPixels" (BYVAL W AS LONG, BYVAL H AS LONG, BYVAL PFormat AS DWORD, BYVAL PType AS DWORD, BYVAL pixelPtr AS DWORD)
DECLARE SUB glRasterPos3i LIB "OPENGL32.DLL" ALIAS "glRasterPos3i" (BYVAL x AS LONG, BYVAL y AS LONG, BYVAL z AS LONG)
DECLARE SUB glRasterPos3f LIB "OPENGL32.DLL" ALIAS "glRasterPos3f" (BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
DECLARE SUB glRasterPos4i LIB "OPENGL32.DLL" ALIAS "glRasterPos4i" (BYVAL x AS LONG, BYVAL y AS LONG, BYVAL z AS LONG, BYVAL w AS LONG)
DECLARE SUB glRasterPos4f LIB "OPENGL32.DLL" ALIAS "glRasterPos4f" (BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE, BYVAL w AS SINGLE)
DECLARE FUNCTION glGetError LIB "OPENGL32.DLL" ALIAS "glGetError" () AS DWORD
DECLARE SUB glPixelTransferi LIB "OPENGL32.DLL" ALIAS "glPixelTransferi" (BYVAL pname AS DWORD, BYVAL param AS LONG)
DECLARE SUB glPixelTransferf LIB "OPENGL32.DLL" ALIAS "glPixelTransferf" (BYVAL pname AS DWORD, BYVAL param AS SINGLE)
DECLARE SUB glPixelStorei LIB "OPENGL32.DLL" ALIAS "glPixelStorei" (BYVAL pname AS DWORD, BYVAL param AS LONG)
DECLARE SUB glDrawBuffer LIB "OPENGL32.DLL" ALIAS "glDrawBuffer" (BYVAL MODE AS DWORD)
DECLARE SUB glBitmap LIB "OPENGL32.DLL" ALIAS "glBitmap" (BYVAL W AS LONG, BYVAL H AS LONG, BYVAL X AS SINGLE, BYVAL Y AS SINGLE, BYVAL XM AS SINGLE, BYVAL YM AS SINGLE, BYVAL lpB AS DWORD)
DECLARE SUB glGetIntegerv LIB "OPENGL32.DLL" ALIAS "glGetIntegerv" (BYVAL PN AS DWORD, IValue&)
DECLARE SUB glGetFloatv LIB "OPENGL32.DLL" ALIAS "glGetFloatv" (BYVAL PN AS DWORD, IValue!)
DECLARE SUB glFlush LIB "OPENGL32.DLL" ALIAS "glFlush" ()
DECLARE SUB glFinish LIB "OPENGL32.DLL" ALIAS "glFinish" ()
DECLARE SUB glPixelZoom LIB "OPENGL32.DLL" ALIAS "glPixelZoom" (BYVAL ScaleX!, BYVAL ScaleY!)
DECLARE FUNCTION glGetString LIB "OPENGL32.DLL" ALIAS "glGetString" (BYVAL GLName AS DWORD) AS DWORD
DECLARE SUB glOrtho LIB "OPENGL32.DLL" ALIAS "glOrtho" (BYVAL oLeft AS DOUBLE, BYVAL oRight AS DOUBLE, BYVAL oBottom AS DOUBLE, BYVAL oTop AS DOUBLE, BYVAL oNear AS DOUBLE, BYVAL oFar AS DOUBLE)
DECLARE SUB glDeleteLists LIB "OPENGL32.DLL" ALIAS "glDeleteLists" (BYVAL list AS DWORD, BYVAL Range AS LONG)
DECLARE FUNCTION glGenLists LIB "OPENGL32.DLL" ALIAS "glGenLists" (BYVAL Range AS LONG) AS LONG
DECLARE SUB glTranslatef LIB "OPENGL32.DLL" ALIAS "glTranslatef" (BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
DECLARE SUB glLightfv LIB "OPENGL32.DLL" ALIAS "glLightfv" (BYVAL LightN AS DWORD, BYVAL PName AS DWORD, BYREF Param AS SINGLE)
DECLARE SUB glColorMaterial LIB "OPENGL32.DLL" ALIAS "glColorMaterial" (BYVAL face AS DWORD, BYVAL mode AS DWORD)
DECLARE SUB glMaterialfv LIB "OPENGL32.DLL" ALIAS "glMaterialfv" (BYVAL face AS DWORD,BYVAL PName AS DWORD, BYREF Param AS SINGLE)
DECLARE SUB glMateriali LIB "OPENGL32.DLL" ALIAS "glMateriali" (BYVAL face AS DWORD,BYVAL PName AS DWORD, BYVAL Param AS LONG)
DECLARE SUB glPushMatrix LIB "OPENGL32.DLL" ALIAS "glPushMatrix" ()
DECLARE SUB glPopMatrix LIB "OPENGL32.DLL" ALIAS "glPopMatrix" ()
DECLARE SUB glNormal3f LIB "OPENGL32.DLL" ALIAS "glNormal3f" (BYVAL x AS SINGLE, BYVAL y AS SINGLE, BYVAL z AS SINGLE)
DECLARE SUB glFrontFace LIB "OPENGL32.DLL" ALIAS "glFrontFace" (BYVAL mode AS DWORD)
DECLARE SUB glLightModelfv LIB "OPENGL32.DLL" ALIAS "glLightModelfv" (BYVAL PName AS DWORD, BYREF Param AS SINGLE)
DECLARE SUB glShadeModel LIB "OPENGL32.DLL" ALIAS "glShadeModel" (BYVAL mode AS DWORD)
DECLARE SUB glBlendFunc LIB "OPENGL32.DLL" ALIAS "glBlendFunc" (BYVAL SFactor AS DWORD, BYVAL DFactor AS DWORD)
DECLARE SUB glPolygonMode LIB "OPENGL32.DLL" ALIAS "glPolygonMode" (BYVAL Face AS DWORD, BYVAL mode AS DWORD)
DECLARE SUB glLineWidth LIB "OPENGL32.DLL" ALIAS "glLineWidth" (BYVAL W AS SINGLE)
DECLARE SUB glTexCoord2f LIB "OPENGL32.DLL" ALIAS "glTexCoord2f" (BYVAL s AS SINGLE, BYVAL t AS SINGLE)
DECLARE SUB glTexParameteri LIB "OPENGL32.DLL" ALIAS "glTexParameteri" (BYVAL target AS DWORD, BYVAL pname AS DWORD, BYVAL param AS LONG)
DECLARE SUB glTexEnvi LIB "OPENGL32.DLL" ALIAS "glTexEnvi" (BYVAL target AS DWORD, BYVAL pname AS DWORD, BYVAL param AS LONG)
DECLARE SUB glTexImage2D LIB "OPENGL32.DLL" ALIAS "glTexImage2D" (BYVAL targ AS DWORD, BYVAL lev AS LONG, BYVAL iformat AS LONG, BYVAL w AS LONG, BYVAL h AS LONG, _
                                                                  BYVAL brd AS LONG, BYVAL format AS DWORD, BYVAL Tp AS DWORD, BYVAL lpPixel AS DWORD)

DECLARE SUB glColorPointer LIB "OPENGL32.DLL" ALIAS "glColorPointer" (BYVAL ASize AS LONG, BYVAL aType AS DWORD, BYVAL Stride AS LONG, BYVAL lpArray AS DWORD)
DECLARE SUB glNormalPointer LIB "OPENGL32.DLL" ALIAS "glNormalPointer" (BYVAL aType AS DWORD, BYVAL Stride AS LONG, BYVAL lpArray AS DWORD)
DECLARE SUB glTexCoordPointer LIB "OPENGL32.DLL" ALIAS "glTexCoordPointer" (BYVAL ASize AS LONG, BYVAL aType AS DWORD, BYVAL Stride AS LONG, BYVAL lpArray AS DWORD)
DECLARE SUB glVertexPointer LIB "OPENGL32.DLL" ALIAS "glVertexPointer" (BYVAL ASize AS LONG, BYVAL aType AS DWORD, BYVAL Stride AS LONG, BYVAL lpArray AS DWORD)
DECLARE SUB glEnableClientState LIB "OPENGL32.DLL" ALIAS "glEnableClientState" (BYVAL WhichArrays AS DWORD)
DECLARE SUB glDisableClientState LIB "OPENGL32.DLL" ALIAS "glDisableClientState" (BYVAL WhichArrays AS DWORD)
DECLARE SUB glDrawArrays LIB "OPENGL32.DLL" ALIAS "glDrawArrays" (BYVAL mode AS DWORD, BYVAL First AS LONG, BYVAL Count AS LONG)


' DECLARE SUB gl LIB "OPENGL32.DLL" ALIAS "" ()
' DECLARE SUB gl LIB "OPENGL32.DLL" ALIAS "" ()
' DECLARE SUB gl LIB "OPENGL32.DLL" ALIAS "" ()
' DECLARE SUB gl LIB "OPENGL32.DLL" ALIAS "" ()
' DECLARE SUB gl LIB "OPENGL32.DLL" ALIAS "" ()
' DECLARE SUB gl LIB "OPENGL32.DLL" ALIAS "" ()

' GLU Declares
' ============
DECLARE SUB gluPerspective LIB "GLU32.DLL" ALIAS "gluPerspective" (BYVAL fovy AS DOUBLE, BYVAL aspect AS DOUBLE, BYVAL znear AS DOUBLE, BYVAL zfar AS DOUBLE)
DECLARE SUB gluLookAt LIB "GLU32.DLL" ALIAS "gluLookAt" (BYVAL eyex AS DOUBLE,BYVAL eyey AS DOUBLE,BYVAL eyez AS DOUBLE,_
                                                              BYVAL centerx AS DOUBLE, BYVAL centery AS DOUBLE,BYVAL centerz AS DOUBLE,_
                                                              BYVAL upx AS DOUBLE,BYVAL upy AS DOUBLE,BYVAL upz AS DOUBLE)

DECLARE FUNCTION gluNewQuadric LIB "GLU32.DLL" ALIAS "gluNewQuadric" () AS DWORD
DECLARE SUB gluDeleteQuadric LIB "GLU32.DLL" ALIAS "gluDeleteQuadric" (BYVAL qobj AS DWORD)
DECLARE SUB gluQuadricDrawStyle LIB "GLU32.DLL" ALIAS "gluQuadricDrawStyle" (BYVAL qobj AS DWORD, BYVAL style AS DWORD)
DECLARE SUB gluQuadricNormals LIB "GLU32.DLL" ALIAS "gluQuadricNormals" (BYVAL qobj AS DWORD, BYVAL normal AS DWORD)
DECLARE SUB gluQuadricOrientation LIB "GLU32.DLL" ALIAS "gluQuadricOrientation" (BYVAL qobj AS DWORD, BYVAL orient AS DWORD)
DECLARE SUB gluQuadricTexture LIB "GLU32.DLL" ALIAS "gluQuadricTexture" (BYVAL qobj AS DWORD, BYVAL texturecoords AS DWORD)
DECLARE SUB gluBuild2DMipmaps LIB "GLU32.DLL" ALIAS "gluBuild2DMipmaps" (BYVAL targ AS DWORD, BYVAL cmp AS LONG, BYVAL w AS LONG, BYVAL h AS LONG, BYVAL format AS DWORD, BYVAL Tp AS DWORD, BYVAL lpPixels AS DWORD)
DECLARE SUB gluSphere LIB "GLU32.DLL" ALIAS "gluSphere" (BYVAL qobj AS DWORD, BYVAL Radius AS DOUBLE, BYVAL slices AS LONG, BYVAL stacks AS LONG)
DECLARE SUB gluCylinder LIB "GLU32.DLL" ALIAS "gluCylinder" (BYVAL qobj AS DWORD, BYVAL BaseRadius AS DOUBLE, BYVAL TopRadius AS DOUBLE, BYVAL Height AS DOUBLE, BYVAL slices AS LONG, BYVAL stacks AS LONG)
DECLARE SUB gluDisk LIB "GLU32.DLL" ALIAS "gluDisk" (BYVAL qobj AS DWORD, BYVAL InRadius AS DOUBLE, BYVAL OutRadius AS DOUBLE, BYVAL slices AS LONG, BYVAL loops AS LONG)

' DECLARE SUB glu LIB "GLU32.DLL" ALIAS "" ()
' DECLARE SUB glu LIB "GLU32.DLL" ALIAS "" ()
' DECLARE SUB glu LIB "GLU32.DLL" ALIAS "" ()
' DECLARE SUB glu LIB "GLU32.DLL" ALIAS "" ()
' DECLARE SUB glu LIB "GLU32.DLL" ALIAS "" ()
' DECLARE SUB glu LIB "GLU32.DLL" ALIAS "" ()
' ---------------------------------------------------
'      prevent code from being used until converted
' ---------------------------------------------------
#IF 0
' ---------------------------------------------------


' ---------------------------------------------------
#ENDIF
' ---------------------------------------------------

' ---------------------------------------------------
'      prevent code from being used until converted
' ---------------------------------------------------

' ---------------------------------------------------
' Windows OpenGL extensions:
' ---------------------------------------------------

' -----------------
#IF %DefineWGLCalls
' -----------------

%WGL_WGLEXT_VERSION  = 9
%WGL_FRONT_COLOR_BUFFER_BIT_ARB  = &H00000001
%WGL_BACK_COLOR_BUFFER_BIT_ARB   = &H00000002
%WGL_DEPTH_BUFFER_BIT_ARB        = &H00000004
%WGL_STENCIL_BUFFER_BIT_ARB      = &H00000008
%WGL_SAMPLE_BUFFERS_ARB          = &H00002041
%WGL_SAMPLES_ARB                 = &H00002042
%WGL_NUMBER_PIXEL_FORMATS_ARB    = &H00002000
%WGL_DRAW_TO_WINDOW_ARB          = &H00002001
%WGL_DRAW_TO_BITMAP_ARB          = &H00002002
%WGL_ACCELERATION_ARB            = &H00002003
%WGL_NEED_PALETTE_ARB            = &H00002004
%WGL_NEED_SYSTEM_PALETTE_ARB     = &H00002005
%WGL_SWAP_LAYER_BUFFERS_ARB      = &H00002006
%WGL_SWAP_METHOD_ARB             = &H00002007
%WGL_NUMBER_OVERLAYS_ARB         = &H00002008
%WGL_NUMBER_UNDERLAYS_ARB        = &H00002009
%WGL_TRANSPARENT_ARB             = &H0000200A
%WGL_TRANSPARENT_RED_VALUE_ARB   = &H00002037
%WGL_TRANSPARENT_GREEN_VALUE_ARB  = &H00002038
%WGL_TRANSPARENT_BLUE_VALUE_ARB  = &H00002039
%WGL_TRANSPARENT_ALPHA_VALUE_ARB  = &H0000203A
%WGL_TRANSPARENT_INDEX_VALUE_ARB  = &H0000203B
%WGL_SHARE_DEPTH_ARB             = &H0000200C
%WGL_SHARE_STENCIL_ARB           = &H0000200D
%WGL_SHARE_ACCUM_ARB             = &H0000200E
%WGL_SUPPORT_GDI_ARB             = &H0000200F
%WGL_SUPPORT_OPENGL_ARB          = &H00002010
%WGL_DOUBLE_BUFFER_ARB           = &H00002011
%WGL_STEREO_ARB                  = &H00002012
%WGL_PIXEL_TYPE_ARB              = &H00002013
%WGL_COLOR_BITS_ARB              = &H00002014
%WGL_RED_BITS_ARB                = &H00002015
%WGL_RED_SHIFT_ARB               = &H00002016
%WGL_GREEN_BITS_ARB              = &H00002017
%WGL_GREEN_SHIFT_ARB             = &H00002018
%WGL_BLUE_BITS_ARB               = &H00002019
%WGL_BLUE_SHIFT_ARB              = &H0000201A
%WGL_ALPHA_BITS_ARB              = &H0000201B
%WGL_ALPHA_SHIFT_ARB             = &H0000201C
%WGL_ACCUM_BITS_ARB              = &H0000201D
%WGL_ACCUM_RED_BITS_ARB          = &H0000201E
%WGL_ACCUM_GREEN_BITS_ARB        = &H0000201F
%WGL_ACCUM_BLUE_BITS_ARB         = &H00002020
%WGL_ACCUM_ALPHA_BITS_ARB        = &H00002021
%WGL_DEPTH_BITS_ARB              = &H00002022
%WGL_STENCIL_BITS_ARB            = &H00002023
%WGL_AUX_BUFFERS_ARB             = &H00002024
%WGL_NO_ACCELERATION_ARB         = &H00002025
%WGL_GENERIC_ACCELERATION_ARB    = &H00002026
%WGL_FULL_ACCELERATION_ARB       = &H00002027
%WGL_SWAP_EXCHANGE_ARB           = &H00002028
%WGL_SWAP_COPY_ARB               = &H00002029
%WGL_SWAP_UNDEFINED_ARB          = &H0000202A
%WGL_TYPE_RGBA_ARB               = &H0000202B
%WGL_TYPE_COLORINDEX_ARB         = &H0000202C
%ERROR_INVALID_PIXEL_TYPE_ARB    = &H00002043
%ERROR_INCOMPATIBLE_DEVICE_CONTEXTS_ARB  = &H00002054
%WGL_DRAW_TO_PBUFFER_ARB         = &H0000202D
%WGL_MAX_PBUFFER_PIXELS_ARB      = &H0000202E
%WGL_MAX_PBUFFER_WIDTH_ARB       = &H0000202F
%WGL_MAX_PBUFFER_HEIGHT_ARB      = &H00002030
%WGL_PBUFFER_LARGEST_ARB         = &H00002033
%WGL_PBUFFER_WIDTH_ARB           = &H00002034
%WGL_PBUFFER_HEIGHT_ARB          = &H00002035
%WGL_PBUFFER_LOST_ARB            = &H00002036
%WGL_BIND_TO_TEXTURE_RGB_ARB     = &H00002070
%WGL_BIND_TO_TEXTURE_RGBA_ARB    = &H00002071
%WGL_TEXTURE_FORMAT_ARB          = &H00002072
%WGL_TEXTURE_TARGET_ARB          = &H00002073
%WGL_MIPMAP_TEXTURE_ARB          = &H00002074
%WGL_TEXTURE_RGB_ARB             = &H00002075
%WGL_TEXTURE_RGBA_ARB            = &H00002076
%WGL_NO_TEXTURE_ARB              = &H00002077
%WGL_TEXTURE_CUBE_MAP_ARB        = &H00002078
%WGL_TEXTURE_1D_ARB              = &H00002079
%WGL_TEXTURE_2D_ARB              = &H0000207A
%WGL_MIPMAP_LEVEL_ARB            = &H0000207B
%WGL_CUBE_MAP_FACE_ARB           = &H0000207C
%WGL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB  = &H0000207D
%WGL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB  = &H0000207E
%WGL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB  = &H0000207F
%WGL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB  = &H00002080
%WGL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB  = &H00002081
%WGL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB  = &H00002082
%WGL_FRONT_LEFT_ARB              = &H00002083
%WGL_FRONT_RIGHT_ARB             = &H00002084
%WGL_BACK_LEFT_ARB               = &H00002085
%WGL_BACK_RIGHT_ARB              = &H00002086
%WGL_AUX0_ARB                    = &H00002087
%WGL_AUX1_ARB                    = &H00002088
%WGL_AUX2_ARB                    = &H00002089
%WGL_AUX3_ARB                    = &H0000208A
%WGL_AUX4_ARB                    = &H0000208B
%WGL_AUX5_ARB                    = &H0000208C
%WGL_AUX6_ARB                    = &H0000208D
%WGL_AUX7_ARB                    = &H0000208E
%WGL_AUX8_ARB                    = &H0000208F
%WGL_AUX9_ARB                    = &H00002090
%WGL_TYPE_RGBA_FLOAT_ARB         = &H000021A0
%ERROR_INVALID_PIXEL_TYPE_EXT    = &H00002043
%WGL_NUMBER_PIXEL_FORMATS_EXT    = &H00002000
%WGL_DRAW_TO_WINDOW_EXT          = &H00002001
%WGL_DRAW_TO_BITMAP_EXT          = &H00002002
%WGL_ACCELERATION_EXT            = &H00002003
%WGL_NEED_PALETTE_EXT            = &H00002004
%WGL_NEED_SYSTEM_PALETTE_EXT     = &H00002005
%WGL_SWAP_LAYER_BUFFERS_EXT      = &H00002006
%WGL_SWAP_METHOD_EXT             = &H00002007
%WGL_NUMBER_OVERLAYS_EXT         = &H00002008
%WGL_NUMBER_UNDERLAYS_EXT        = &H00002009
%WGL_TRANSPARENT_EXT             = &H0000200A
%WGL_TRANSPARENT_VALUE_EXT       = &H0000200B
%WGL_SHARE_DEPTH_EXT             = &H0000200C
%WGL_SHARE_STENCIL_EXT           = &H0000200D
%WGL_SHARE_ACCUM_EXT             = &H0000200E
%WGL_SUPPORT_GDI_EXT             = &H0000200F
%WGL_SUPPORT_OPENGL_EXT          = &H00002010
%WGL_DOUBLE_BUFFER_EXT           = &H00002011
%WGL_STEREO_EXT                  = &H00002012
%WGL_PIXEL_TYPE_EXT              = &H00002013
%WGL_COLOR_BITS_EXT              = &H00002014
%WGL_RED_BITS_EXT                = &H00002015
%WGL_RED_SHIFT_EXT               = &H00002016
%WGL_GREEN_BITS_EXT              = &H00002017
%WGL_GREEN_SHIFT_EXT             = &H00002018
%WGL_BLUE_BITS_EXT               = &H00002019
%WGL_BLUE_SHIFT_EXT              = &H0000201A
%WGL_ALPHA_BITS_EXT              = &H0000201B
%WGL_ALPHA_SHIFT_EXT             = &H0000201C
%WGL_ACCUM_BITS_EXT              = &H0000201D
%WGL_ACCUM_RED_BITS_EXT          = &H0000201E
%WGL_ACCUM_GREEN_BITS_EXT        = &H0000201F
%WGL_ACCUM_BLUE_BITS_EXT         = &H00002020
%WGL_ACCUM_ALPHA_BITS_EXT        = &H00002021
%WGL_DEPTH_BITS_EXT              = &H00002022
%WGL_STENCIL_BITS_EXT            = &H00002023
%WGL_AUX_BUFFERS_EXT             = &H00002024
%WGL_NO_ACCELERATION_EXT         = &H00002025
%WGL_GENERIC_ACCELERATION_EXT    = &H00002026
%WGL_FULL_ACCELERATION_EXT       = &H00002027
%WGL_SWAP_EXCHANGE_EXT           = &H00002028
%WGL_SWAP_COPY_EXT               = &H00002029
%WGL_SWAP_UNDEFINED_EXT          = &H0000202A
%WGL_TYPE_RGBA_EXT               = &H0000202B
%WGL_TYPE_COLORINDEX_EXT         = &H0000202C
%WGL_DRAW_TO_PBUFFER_EXT         = &H0000202D
%WGL_MAX_PBUFFER_PIXELS_EXT      = &H0000202E
%WGL_MAX_PBUFFER_WIDTH_EXT       = &H0000202F
%WGL_MAX_PBUFFER_HEIGHT_EXT      = &H00002030
%WGL_OPTIMAL_PBUFFER_WIDTH_EXT   = &H00002031
%WGL_OPTIMAL_PBUFFER_HEIGHT_EXT  = &H00002032
%WGL_PBUFFER_LARGEST_EXT         = &H00002033
%WGL_PBUFFER_WIDTH_EXT           = &H00002034
%WGL_PBUFFER_HEIGHT_EXT          = &H00002035
%WGL_DEPTH_FLOAT_EXT             = &H00002040
%WGL_SAMPLE_BUFFERS_3DFX         = &H00002060
%WGL_SAMPLES_3DFX                = &H00002061
%WGL_SAMPLE_BUFFERS_EXT          = &H00002041
%WGL_SAMPLES_EXT                 = &H00002042
%WGL_DIGITAL_VIDEO_CURSOR_ALPHA_FRAMEBUFFER_I3D  = &H00002050
%WGL_DIGITAL_VIDEO_CURSOR_ALPHA_VALUE_I3D  = &H00002051
%WGL_DIGITAL_VIDEO_CURSOR_INCLUDED_I3D  = &H00002052
%WGL_DIGITAL_VIDEO_GAMMA_CORRECTED_I3D  = &H00002053
%WGL_GAMMA_TABLE_SIZE_I3D        = &H0000204E
%WGL_GAMMA_EXCLUDE_DESKTOP_I3D   = &H0000204F
%WGL_GENLOCK_SOURCE_MULTIVIEW_I3D  = &H00002044
%WGL_GENLOCK_SOURCE_EXTENAL_SYNC_I3D  = &H00002045
%WGL_GENLOCK_SOURCE_EXTENAL_FIELD_I3D  = &H00002046
%WGL_GENLOCK_SOURCE_EXTENAL_TTL_I3D  = &H00002047
%WGL_GENLOCK_SOURCE_DIGITAL_SYNC_I3D  = &H00002048
%WGL_GENLOCK_SOURCE_DIGITAL_FIELD_I3D  = &H00002049
%WGL_GENLOCK_SOURCE_EDGE_FALLING_I3D  = &H0000204A
%WGL_GENLOCK_SOURCE_EDGE_RISING_I3D  = &H0000204B
%WGL_GENLOCK_SOURCE_EDGE_BOTH_I3D  = &H0000204C
%WGL_IMAGE_BUFFER_MIN_ACCESS_I3D  = &H00000001
%WGL_IMAGE_BUFFER_LOCK_I3D       = &H00000002
%WGL_BIND_TO_TEXTURE_DEPTH_NV    = &H000020A3
%WGL_BIND_TO_TEXTURE_RECTANGLE_DEPTH_NV  = &H000020A4
%WGL_DEPTH_TEXTURE_FORMAT_NV     = &H000020A5
%WGL_TEXTURE_DEPTH_COMPONENT_NV  = &H000020A6
%WGL_DEPTH_COMPONENT_NV          = &H000020A7
%WGL_BIND_TO_TEXTURE_RECTANGLE_RGB_NV  = &H000020A0
%WGL_BIND_TO_TEXTURE_RECTANGLE_RGBA_NV  = &H000020A1
%WGL_TEXTURE_RECTANGLE_NV        = &H000020A2
%WGL_TYPE_RGBA_FLOAT_ATI         = &H000021A0
%WGL_FLOAT_COMPONENTS_NV         = &H000020B0
%WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_R_NV  = &H000020B1
%WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_RG_NV  = &H000020B2
%WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_RGB_NV  = &H000020B3
%WGL_BIND_TO_TEXTURE_RECTANGLE_FLOAT_RGBA_NV  = &H000020B4
%WGL_TEXTURE_FLOAT_R_NV          = &H000020B5
%WGL_TEXTURE_FLOAT_RG_NV         = &H000020B6
%WGL_TEXTURE_FLOAT_RGB_NV        = &H000020B7
%WGL_TEXTURE_FLOAT_RGBA_NV       = &H000020B8
%WGL_STEREO_EMITTER_ENABLE_3DL   = &H00002055
%WGL_STEREO_EMITTER_DISABLE_3DL  = &H00002056
%WGL_STEREO_POLARITY_NORMAL_3DL  = &H00002057
%WGL_STEREO_POLARITY_INVERT_3DL  = &H00002058
%WGL_TYPE_RGBA_UNSIGNED_FLOAT_EXT  = &H000020A8
%WGL_FRAMEBUFFER_SRGB_CAPABLE_EXT  = &H000020A9

' ---------------------------------------------------
' OpenGL Windows Extension Declares (wgl functions)
' ---------------------------------------------------
' pixel types
%PFD_TYPE_RGBA       = 0
%PFD_TYPE_COLORINDEX = 1

' layer types
%PFD_MAIN_PLANE     = 0
%PFD_OVERLAY_PLANE  = 1
%PFD_UNDERLAY_PLANE = -1

' PIXELFORMATDESCRIPTOR flags
%PFD_DOUBLEBUFFER          = &H00000001
%PFD_STEREO                = &H00000002
%PFD_DRAW_TO_WINDOW        = &H00000004
%PFD_DRAW_TO_BITMAP        = &H00000008
%PFD_SUPPORT_GDI           = &H00000010
%PFD_SUPPORT_OPENGL        = &H00000020
%PFD_GENERIC_FORMAT        = &H00000040
%PFD_NEED_PALETTE          = &H00000080
%PFD_NEED_SYSTEM_PALETTE   = &H00000100
%PFD_SWAP_EXCHANGE         = &H00000200
%PFD_SWAP_COPY             = &H00000400
%PFD_SWAP_LAYER_BUFFERS    = &H00000800
%PFD_GENERIC_ACCELERATED   = &H00001000
%PFD_SUPPORT_DIRECTDRAW    = &H00002000
%PFD_SUPPORT_COMPOSITION   = &H00008000     ' found on the web a new flag

' PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only
%PFD_DEPTH_DONTCARE        = &H20000000
%PFD_DOUBLEBUFFER_DONTCARE = &H40000000
%PFD_STEREO_DONTCARE       = &H80000000

' prototype:
' DECLARE FUNCTION myname LIB "OPENGL32.DLL" ALIAS "myname" () AS LONG

DECLARE FUNCTION wglCreateContext LIB "OPENGL32.DLL" ALIAS "wglCreateContext" (BYVAL hDC AS LONG) AS LONG
DECLARE FUNCTION wglMakeCurrent LIB "OPENGL32.DLL" ALIAS "wglMakeCurrent" (BYVAL hDC AS LONG, BYVAL hglRC AS LONG) AS LONG
DECLARE FUNCTION wglDeleteContext LIB "OPENGL32.DLL" ALIAS "wglDeleteContext" (BYVAL hglRC AS LONG) AS LONG
DECLARE FUNCTION wglGetCurrentContext LIB "OPENGL32.DLL" ALIAS "wglGetCurrentContext" () AS LONG
DECLARE FUNCTION wglGetProcAddress LIB "OPENGL32.DLL" ALIAS "wglGetProcAddress" (lpzText AS ASCIIZ) AS LONG
' DECLARE FUNCTION wgl LIB "OPENGL32.DLL" ALIAS "" () AS LONG
' DECLARE FUNCTION wgl LIB "OPENGL32.DLL" ALIAS "" () AS LONG
' DECLARE FUNCTION wgl LIB "OPENGL32.DLL" ALIAS "" () AS LONG
' DECLARE FUNCTION wgl LIB "OPENGL32.DLL" ALIAS "" () AS LONG

' -----------------
#ENDIF
' -----------------


' ---------------------------------------------------
#IF 0
' ---------------------------------------------------


'extern HANDLE WINAPI wglCreateBufferRegionARB (HDC, int, UINT)
'extern VOID WINAPI wglDeleteBufferRegionARB (HANDLE)
'extern BOOL WINAPI wglSaveBufferRegionARB (HANDLE, int, int, int, int)
'extern BOOL WINAPI wglRestoreBufferRegionARB (HANDLE, int, int, int, int, int, int)
'extern const char * WINAPI wglGetExtensionsStringARB (HDC)
'extern BOOL WINAPI wglGetPixelFormatAttribivARB (HDC, int, int, UINT, const int *, int *)
'extern BOOL WINAPI wglGetPixelFormatAttribfvARB (HDC, int, int, UINT, const int *, FLOAT *)
'extern BOOL WINAPI wglChoosePixelFormatARB (HDC, const int *, const FLOAT *, UINT, int *, UINT *)
'extern BOOL WINAPI wglMakeContextCurrentARB (HDC, HDC, HGLRC)
'extern HDC WINAPI wglGetCurrentReadDCARB (void)
'extern HPBUFFERARB WINAPI wglCreatePbufferARB (HDC, int, int, int, const int *)
'extern HDC WINAPI wglGetPbufferDCARB (HPBUFFERARB)
'extern int WINAPI wglReleasePbufferDCARB (HPBUFFERARB, HDC)
'extern BOOL WINAPI wglDestroyPbufferARB (HPBUFFERARB)
'extern BOOL WINAPI wglQueryPbufferARB (HPBUFFERARB, int, int *)
'extern BOOL WINAPI wglBindTexImageARB (HPBUFFERARB, int)
'extern BOOL WINAPI wglReleaseTexImageARB (HPBUFFERARB, int)
'extern BOOL WINAPI wglSetPbufferAttribARB (HPBUFFERARB, const int *)
'extern GLboolean WINAPI wglCreateDisplayColorTableEXT (GLushort)
'extern GLboolean WINAPI wglLoadDisplayColorTableEXT (const GLushort *, GLuint)
'extern GLboolean WINAPI wglBindDisplayColorTableEXT (GLushort)
'extern VOID WINAPI wglDestroyDisplayColorTableEXT (GLushort)
'extern const char * WINAPI wglGetExtensionsStringEXT (void)
'extern BOOL WINAPI wglMakeContextCurrentEXT (HDC, HDC, HGLRC)
'extern HDC WINAPI wglGetCurrentReadDCEXT (void)
'extern HPBUFFEREXT WINAPI wglCreatePbufferEXT (HDC, int, int, int, const int *)
'extern HDC WINAPI wglGetPbufferDCEXT (HPBUFFEREXT)
'extern int WINAPI wglReleasePbufferDCEXT (HPBUFFEREXT, HDC)
'extern BOOL WINAPI wglDestroyPbufferEXT (HPBUFFEREXT)
'extern BOOL WINAPI wglQueryPbufferEXT (HPBUFFEREXT, int, int *)
'extern BOOL WINAPI wglGetPixelFormatAttribivEXT (HDC, int, int, UINT, int *, int *)
'extern BOOL WINAPI wglGetPixelFormatAttribfvEXT (HDC, int, int, UINT, int *, FLOAT *)
'extern BOOL WINAPI wglChoosePixelFormatEXT (HDC, const int *, const FLOAT *, UINT, int *, UINT *)
'extern BOOL WINAPI wglSwapIntervalEXT (int)
'extern int WINAPI wglGetSwapIntervalEXT (void)
'extern void* WINAPI wglAllocateMemoryNV (GLsizei, GLfloat, GLfloat, GLfloat)
'extern void WINAPI wglFreeMemoryNV (void *)
'extern BOOL WINAPI wglGetSyncValuesOML (HDC, INT64 *, INT64 *, INT64 *)
'extern BOOL WINAPI wglGetMscRateOML (HDC, INT32 *, INT32 *)
'extern INT64 WINAPI wglSwapBuffersMscOML (HDC, INT64, INT64, INT64)
'extern INT64 WINAPI wglSwapLayerBuffersMscOML (HDC, int, INT64, INT64, INT64)
'extern BOOL WINAPI wglWaitForMscOML (HDC, INT64, INT64, INT64, INT64 *, INT64 *, INT64 *)
'extern BOOL WINAPI wglWaitForSbcOML (HDC, INT64, INT64 *, INT64 *, INT64 *)
'extern BOOL WINAPI wglGetDigitalVideoParametersI3D (HDC, int, int *)
'extern BOOL WINAPI wglSetDigitalVideoParametersI3D (HDC, int, const int *)
'extern BOOL WINAPI wglGetGammaTableParametersI3D (HDC, int, int *)
'extern BOOL WINAPI wglSetGammaTableParametersI3D (HDC, int, const int *)
'extern BOOL WINAPI wglGetGammaTableI3D (HDC, int, USHORT *, USHORT *, USHORT *)
'extern BOOL WINAPI wglSetGammaTableI3D (HDC, int, const USHORT *, const USHORT *, const USHORT *)
'extern BOOL WINAPI wglEnableGenlockI3D (HDC)
'extern BOOL WINAPI wglDisableGenlockI3D (HDC)
'extern BOOL WINAPI wglIsEnabledGenlockI3D (HDC, BOOL *)
'extern BOOL WINAPI wglGenlockSourceI3D (HDC, UINT)
'extern BOOL WINAPI wglGetGenlockSourceI3D (HDC, UINT *)
'extern BOOL WINAPI wglGenlockSourceEdgeI3D (HDC, UINT)
'extern BOOL WINAPI wglGetGenlockSourceEdgeI3D (HDC, UINT *)
'extern BOOL WINAPI wglGenlockSampleRateI3D (HDC, UINT)
'extern BOOL WINAPI wglGetGenlockSampleRateI3D (HDC, UINT *)
'extern BOOL WINAPI wglGenlockSourceDelayI3D (HDC, UINT)
'extern BOOL WINAPI wglGetGenlockSourceDelayI3D (HDC, UINT *)
'extern BOOL WINAPI wglQueryGenlockMaxSourceDelayI3D (HDC, UINT *, UINT *)
'extern LPVOID WINAPI wglCreateImageBufferI3D (HDC, DWORD, UINT)
'extern BOOL WINAPI wglDestroyImageBufferI3D (HDC, LPVOID)
'extern BOOL WINAPI wglAssociateImageBufferEventsI3D (HDC, const HANDLE *, const LPVOID *, const DWORD *, UINT)
'extern BOOL WINAPI wglReleaseImageBufferEventsI3D (HDC, const LPVOID *, UINT)
'extern BOOL WINAPI wglEnableFrameLockI3D (void)
'extern BOOL WINAPI wglDisableFrameLockI3D (void)
'extern BOOL WINAPI wglIsEnabledFrameLockI3D (BOOL *)
'extern BOOL WINAPI wglQueryFrameLockMasterI3D (BOOL *)
'extern BOOL WINAPI wglGetFrameUsageI3D (float *)
'extern BOOL WINAPI wglBeginFrameTrackingI3D (void)
'extern BOOL WINAPI wglEndFrameTrackingI3D (void)
'extern BOOL WINAPI wglQueryFrameTrackingI3D (DWORD *, DWORD *, float *)

' ---------------------------------------------------
#ENDIF
' ---------------------------------------------------
