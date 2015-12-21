#include "mbed.h"
#include "IOE2015.h"
#include "IOE2015_extrn.h"

//Path buffer control
//**********************************************************
// Initialize Path buffer to reset
void InitPathBuf() {

//    StopMotion();                 // Stop motor motion
    
    PointerOut=0;                   // initialize output pointer
    PointerIn=0;                    // initialize input pointer
    DataInPathBuf=0;                // number of paths in buffer
    SpaceAvailable=BUFFER_SIZE;     // buffer space available 
    StepTimer=STEP_TIMER;           // 60Hz step timer, adds hold time
    PathTimer=PATH_TIMER;           // 60Hz path timer 
    
    PathsExecuted=0;                // total number of paths executed
    PathsPlusBuf=0;                 // total number of paths executed plus paths in buffer
}

//**********************************************************
//Write data to all 5 path encoder buffers
void WritePathData(){

    ++PointerIn;                // increment data in pointer

    if(PointerIn==BUFFER_SIZE-1)
        PointerIn=0;            // roll over pointer

    ++DataInPathBuf;            // increment path counter   
    if(PointerIn==PointerOut)
        path_error=1;
    else {
        (PathBuffer1[PointerIn])=PathIn[0];
        (PathBuffer2[PointerIn])=PathIn[1];
        (PathBuffer3[PointerIn])=PathIn[2];
        (PathBuffer4[PointerIn])=PathIn[3];
        (PathBuffer5[PointerIn])=PathIn[4];
        path_error=0;
    }
}    

//**********************************************************    
//Read path data for all 5 encoder output buffers   
void ReadPathData() {
  
    if(DataInPathBuf==0)
        status_byte|=0x02;              //  Tried to read from empty Buffer, data lost
    else {
        ++PointerOut;                   // increment data out pointer
        --DataInPathBuf;                // decrement path counter

        if(PointerOut==BUFFER_SIZE-1)
            PointerOut=0;               // roll over pointer
        
        PathOut[0]=(PathBuffer1[PointerOut]);
        PathOut[1]=(PathBuffer2[PointerOut]);
        PathOut[2]=(PathBuffer3[PointerOut]);
        PathOut[3]=(PathBuffer4[PointerOut]);
        PathOut[4]=(PathBuffer5[PointerOut]);
                
    }
}

//**********************************************************
// return buffer space available
// 0 = path buffer is empty
int16_t PathSpaceAvail() {
    return(BUFFER_SIZE-DataInPathBuf);
}