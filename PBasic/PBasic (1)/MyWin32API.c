#define _KERNEL32_
#define _USER32_
#define _ADVAPI32_
#define _OLE32_

#define STRICT
#define WIN32_LEAN_AND_MEAN
#define _WIN32_WINNT 0x0400

#include <windows.h>
#include <objbase.h>
#include <oleauto.h>

#include <rttarget.h>

#ifndef NODEBUG
   #define DEBUG
#endif

/*-----------------------------------*/
WINBASEAPI HRESULT WINAPI CoInitialize(LPVOID pvReserved)
{
#ifdef DEBUG
// OutputDebugString("unsupported function CoInitialize called\n");
#endif
   return S_OK;
}

/*-----------------------------------*/
WINBASEAPI void WINAPI CoUninitialize(void)
{
#ifdef DEBUG
// OutputDebugString("unsupported function CoUninitialize called\n");
#endif
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI ScrollConsoleScreenBufferW(
       HANDLE     hConsoleOutput,
 const SMALL_RECT *lpScrollRectangle,
 const SMALL_RECT *lpClipRectangle,
       COORD      dwDestinationOrigin,
 const CHAR_INFO  *lpFill)
{
   if (lpScrollRectangle->Left == 0 && 
       dwDestinationOrigin.X   == 0 && 
       dwDestinationOrigin.Y   == 0)
   {
      RTDisplayScroll(lpScrollRectangle->Left,
                      lpScrollRectangle->Top-1,
                      lpScrollRectangle->Right  - lpScrollRectangle->Left + 1,
                      lpScrollRectangle->Bottom - lpScrollRectangle->Top + 2,
                      lpFill ? lpFill->Char.AsciiChar : ' ');
   }
#ifdef DEBUG
   else
      OutputDebugString("unsupported function ScrollConsoleScreenBufferW called\n");
#endif
   return TRUE;
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI PeekConsoleInputW(HANDLE hConsoleInput,
                                         PINPUT_RECORD lpBuffer,
                                         DWORD nLength,
                                         LPDWORD lpNumberOfEventsRead)
{
   return PeekConsoleInputA(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead);
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI ClearCommError(HANDLE hFile, LPDWORD lpErrors, LPCOMSTAT lpStat)
{
   OutputDebugString("unsupported function ClearCommError called\n");
   return FALSE;
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI EscapeCommFunction(HANDLE hFile, DWORD dwFunc)
{
   OutputDebugString("unsupported function EscapeCommFunction called\n");
   return FALSE;
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI GetCommModemStatus(HANDLE hFile, LPDWORD lpModemStat)
{
   OutputDebugString("unsupported function GetCommModemStatus called\n");
   return FALSE;
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI GetCommProperties(HANDLE hFile, LPCOMMPROP lpCommProp)
{
   OutputDebugString("unsupported function GetCommProperties called\n");
   return FALSE;
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI GetCommState(HANDLE hFile, LPDCB lpDCB)
{
   OutputDebugString("unsupported function GetCommState called\n");
   return FALSE;
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI SetCommState(HANDLE hFile, LPDCB lpDCB)
{
   OutputDebugString("unsupported function SetCommState called\n");
   return FALSE;
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI SetCommTimeouts(HANDLE hFile, LPCOMMTIMEOUTS lpCommTimeouts)
{
   OutputDebugString("unsupported function SetCommTimeouts called\n");
   return FALSE;
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI SetupComm(HANDLE hFile, DWORD dwInQueue, DWORD dwOutQueue)
{
   OutputDebugString("unsupported function SetupComm called\n");
   return FALSE;
}

/*-----------------------------------*/
WINBASEAPI BOOL WINAPI MessageBeep(UINT uType)
{
   Beep(1000, 100);
   return TRUE;
}

/*-----------------------------------*/
WINBASEAPI int WINAPI closesocket(int s)
{
   OutputDebugString("unsupported function closesocket called\n");
   return 0;
}

/*-----------------------------------*/
WINBASEAPI int WINAPI WSACleanup(void)
{
   OutputDebugString("unsupported function WSACleanup called\n");
   return 0;
}
