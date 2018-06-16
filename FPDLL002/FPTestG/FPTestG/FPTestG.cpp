// FPTestG.cpp : Defines the entry point for the application.
// Copyright 2012 Denver Informatics
// http://www.denverinformatics.com

#include "stdafx.h"
#include "FPTestG.h"

const int SCREEN_WIDTH  = 640;
const int SCREEN_HEIGHT = 480;

HINSTANCE      g_hInst;
COLORREF       g_palette[256];
unsigned char  g_8BitScreen[SCREEN_HEIGHT][SCREEN_WIDTH];
struct plot    g_sp;
unsigned char  g_waveform[20000];

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
	case WM_COMMAND:
		switch (LOWORD(wParam))
		{
		case IDM_EXIT:
			DestroyWindow(hWnd);
			break;
		default:
			return DefWindowProc(hWnd, message, wParam, lParam);
		}
		break;

	case WM_PAINT:
		{
			// Prologue
			PAINTSTRUCT ps = {};
			const HDC hdc = BeginPaint(hWnd, &ps);

			// Actual waveform plotting
			static int ipm = FP_PLOT_MODE_PLOT_ONLY;
			fplot(&ipm, &g_sp, g_waveform, reinterpret_cast<unsigned char*>(g_8BitScreen), SCREEN_WIDTH, SCREEN_HEIGHT);

			// Paint white rectangles for window background outside bitmap area.
			// Window has no default background color to minimize flickering
			RECT rc = {};
			GetClientRect(hWnd, &rc);
			const RECT r1 = {0, SCREEN_HEIGHT, rc.right, rc.bottom};
			const RECT r2 = {SCREEN_WIDTH, 0, rc.right, rc.bottom};
			FillRect(hdc, &r1, (HBRUSH)(COLOR_WINDOW+1));
			FillRect(hdc, &r2, (HBRUSH)(COLOR_WINDOW+1));

			// Blit 8-bit virtual screen data into window
			BITMAPINFO bi = {};
			bi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
			bi.bmiHeader.biWidth = SCREEN_WIDTH;
			bi.bmiHeader.biHeight = SCREEN_HEIGHT;
			bi.bmiHeader.biPlanes = 1;
			bi.bmiHeader.biBitCount = 24;
			bi.bmiHeader.biCompression = BI_RGB;
			unsigned char* pBits = NULL;
			const HBITMAP dib = CreateDIBSection(hdc, &bi, DIB_RGB_COLORS, reinterpret_cast<void**>(&pBits), NULL, 0);
			for (int j = 0; j < SCREEN_HEIGHT; j++)
				for (int i = 0; i < SCREEN_WIDTH; i++)
				{
					pBits[j*bi.bmiHeader.biWidth*3 + i*3 + 0] = GetBValue(g_palette[g_8BitScreen[j][i]]);
					pBits[j*bi.bmiHeader.biWidth*3 + i*3 + 1] = GetGValue(g_palette[g_8BitScreen[j][i]]);
					pBits[j*bi.bmiHeader.biWidth*3 + i*3 + 2] = GetRValue(g_palette[g_8BitScreen[j][i]]);
				}
			HDC hdcmem = CreateCompatibleDC(hdc);
			HBITMAP olddib = (HBITMAP)SelectObject(hdcmem, dib);
			BitBlt(hdc, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, hdcmem, 0, 0, SRCCOPY);

			// Epilogue/Clean up
			SelectObject(hdcmem, olddib);
			DeleteObject(dib);
			DeleteDC(hdcmem);
			EndPaint(hWnd, &ps);
		}
		break;

	case WM_TIMER:
		g_sp.idel = (g_sp.idel+3) % 200;
		InvalidateRect(hWnd,NULL,TRUE);
		break;

	case WM_DESTROY:
		PostQuitMessage(0);
		break;

	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}

int APIENTRY _tWinMain(HINSTANCE hInstance,
                       HINSTANCE hPrevInstance,
                       LPTSTR    lpCmdLine,
                       int       nCmdShow)
{
	// Initialize global data

    g_hInst = hInstance;

	for (int i = 0; i < 256; i++)
		g_palette[i] = RGB(i, i, 255);

	g_sp.iscale = 1LL << 32;
	g_sp.ishift = 0;
	g_sp.n      = 400;
	g_sp.xoff   = 100;
	g_sp.yoff   = 50;
	g_sp.lolim  = 0;
	g_sp.hilim  = 639;
	g_sp.color  = 0 ^ 128;
	g_sp.idel   = 0;
	g_sp.irec   = FP_SP_RECTIFY_OFF;
	g_sp.type   = FP_SP_DATA_TWOS_COMPLEMENT;

	for (int i = 0; i < sizeof(g_waveform); i++)
		g_waveform[i] = static_cast<unsigned char>(static_cast<signed char>(127 * sin(i / 10.0)));
	

	// Create and show window

	WNDCLASSEX wcex = {};
	wcex.cbSize        = sizeof(WNDCLASSEX);
	wcex.lpfnWndProc   = WndProc;
	wcex.hInstance     = hInstance;
	wcex.hCursor       = LoadCursor(NULL, IDC_ARROW);
	wcex.lpszMenuName  = MAKEINTRESOURCE(IDC_FPTESTG);
	wcex.lpszClassName = _T("FPTESTG");

	if (!RegisterClassEx(&wcex))
		return FALSE;

    HWND hWnd = CreateWindow(_T("FPTESTG"), _T("FPTestG"), WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);

    if (!hWnd)
        return FALSE;

	const UINT_PTR timer = SetTimer(hWnd, 0, 20, NULL);
    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);


	// Main message loop

	MSG msg = {};
	while (GetMessage(&msg, NULL, 0, 0))
		DispatchMessage(&msg);


	// Cleanup and exit

	KillTimer(hWnd, timer);
	return (int) msg.wParam;
}

