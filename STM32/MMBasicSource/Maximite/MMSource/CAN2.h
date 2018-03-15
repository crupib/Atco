// can2.h
// Copyright 2012 - John Harding
// See license.txt for details of licensing


// Note, to "save" command slots we provide a single CAN command as entry point
// the first argument is a string representing the sub command to call.  Here
// are the available sub-commands
// CAN CONFIG, ok
// CAN SETSPEED, speed, ok
// CAN ADDRXCHNL,
// CAN ADDTXCHNL
// CAN ENABLE, ok
// CAN DISABLE, ok
// CAN FREE
// CAN RX
// CAN TX
// CAN PRINTCONFIG


#if !defined(INCLUDE_COMMAND_TABLE) && !defined(INCLUDE_TOKEN_TABLE)
    void cmd_can (void);
#endif

#ifdef INCLUDE_COMMAND_TABLE
    { "CAN",  T_CMD,  0,  cmd_can },
#endif

