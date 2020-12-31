#COMPILER PBWIN 10
#COMPILE DLL

#INCLUDE ONCE "Win32api.inc"

GLOBAL ghInstance AS DWORD

'-------------------------------------------------------------------------------
' Main DLL entry point called by Windows...
'
FUNCTION LIBMAIN (BYVAL hInstance   AS LONG, _
                  BYVAL fwdReason   AS LONG, _
                  BYVAL lpvReserved AS LONG) AS LONG

    SELECT CASE fwdReason

    CASE %DLL_PROCESS_ATTACH
        'Indicates that the DLL is being loaded by another process (a DLL
        'or EXE is loading the DLL).  DLLs can use this opportunity to
        'initialize any instance or global data, such as arrays.

        ghInstance = hInstance

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!  This will prevent the EXE from running.

    CASE %DLL_PROCESS_DETACH
        'Indicates that the DLL is being unloaded or detached from the
        'calling application.  DLLs can take this opportunity to clean
        'up all resources for all threads attached and known to the DLL.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_ATTACH
        'Indicates that the DLL is being loaded by a new thread in the
        'calling application.  DLLs can use this opportunity to
        'initialize any thread local storage (TLS).

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_DETACH
        'Indicates that the thread is exiting cleanly.  If the DLL has
        'allocated any thread local storage, it should be released.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    END SELECT

END FUNCTION


'-------------------------------------------------------------------------------
' Examples of exported Subs and functions...
'
FUNCTION KLJMessageBox ALIAS "KLJMessageBox" (BYREF Message AS STRING , BYREF title AS STRING, BYVAL typebox AS LONG) EXPORT AS LONG

    KLJMessageBox = MSGBOX(Message , typebox, title)

END FUNCTION


FUNCTION KLJInput ALIAS "KLJInput" (BYREF prompt AS STRING , BYREF title AS STRING, BYREF defaultstring AS STRING, BYVAL xpos AS LONG, BYVAL ypos AS LONG) EXPORT AS STRING

    KLJInput = INPUTBOX$(prompt, title$, defaultstring, xpos, ypos)


END FUNCTION
