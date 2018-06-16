/***********************************************************************************************************************
Maximite

timers.c

This module manages all memory allocation for MMBasic running on the Maximite.
  
Copyright 2011 - 2014 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following 
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.



NOTE:
  In the PIC32 the following variables are set by the linker:
  
      (unsigned char *)&_stack         This is the virtual address of the top of the stack and unless some RAM functions are defined it is also the
                                       top of the RAM.  In this case its value is 0xA0020000.
    
      (unsigned char *)&_splim         This is the virtual address of the top of the heap and represents the start of free and unallocated memory.
      
      (unsigned char *)&_heap          This is the virtual address of the top of the memory allocated by the compiler (static variables, etc)
      
      (unsigned int)&_min_stack_size   This is the number of bytes allocated to the stack.  No run time checking is performed and this value is
                                       only used by the linker to warn if memory is over allocated.
      
  
  The memory map looks like this:
  
  |--------------------|    <<<   0xA0020000  (Top of RAM)
  |  Functions in RAM  |
  |--------------------|    <<<   (unsigned char *)&_stack
  |                    |
  | Stack (grows down) |
  |                    |
  |--------------------|    <<<   (unsigned char *)&_stack - (unsigned int)&_min_stack_size
  |                    |
  |                    |
  |     Free RAM       |
  |                    |
  |                    |
  |--------------------|   <<<   (unsigned char *)&_splim
  |                    |
  | Heap (if allocated)|
  |                    |
  |--------------------|   <<<   (unsigned char *)&_heap
  |                    |
  |                    |
  |                    |
  |  Static RAM Vars   |
  |                    |
  |                    |
  |                    |
  |--------------------|    <<<   0xA0000000
  
  
  The variables must be defined to the C Compiler before using them.  Eg:
      extern unsigned int _stack;
      extern unsigned int _splim;
      extern unsigned int _heap;
      extern unsigned int _min_stack_size;

  
************************************************************************************************************************/



#define INCLUDE_FUNCTION_DEFINES

#include <stdio.h>
#define  __DEBUG


#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

// memory management parameters
#define MEMSIZE         (128 *1024)                                 // the total RAM in the chip
#define PAGESIZE        256                                         // the allocation granuality
#define PAGEBITS        2                                           // nbr of status bits per page of allocated memory, must be a power of 2

#define PUSED           0b01                                        // flag that indicates that the page is in use
#define PLAST           0b10                                        // flag to show that this is the last page in a single allocation

#define PAGESPERWORD    ((sizeof(unsigned int) * 8)/PAGEBITS)
#define RAMSTART        0x20030000

unsigned int mmap[(MEMSIZE/PAGESIZE) / PAGESPERWORD];
char *strtmp[MAXTEMPSTRINGS];                                       // used to track temporary string space on the heap

unsigned char *VarTableTop;

#define MRoundUp(a)     (((a) + (PAGESIZE - 1)) & (~(PAGESIZE - 1)))          // round up to the nearest page size
unsigned int MBitsGet(void *addr);
void MBitsSet(void *addr, int bits);
void *getheap(int size);
unsigned int UsedHeap(void);
void heapstats(char *m1);





/***********************************************************************************************************************
 MMBasic commands
************************************************************************************************************************/


void cmd_memory(void) {
    int i, j, var, nbr, CurrentRAM, vsize, vcnt;
    int pm, pp, vm, vp, gm, gp, vim;
    char *p;
    
    CurrentRAM = (unsigned int)&_stack - (unsigned int)&_min_stack_size - (unsigned int)PMemory;
    
    // calculate the space allocated to variables on the heap
    for(i = vcnt = vsize = var = 0; var < varcnt; var++) {
        if(vartbl[var].type == T_NOTYPE) continue;
        vcnt++;  vsize += sizeof(struct s_vartbl);
        if(vartbl[var].val.s == NULL) continue;
        if(vartbl[var].type & T_PTR) continue;
        nbr = vartbl[var].dims[0] + 1 - OptionBase;
        if(vartbl[var].dims[0]) {
            for(j = 1; j < MAXDIM && vartbl[var].dims[j]; j++)
                nbr *= (vartbl[var].dims[j] + 1 - OptionBase);
            if(vartbl[var].type & T_NBR) {
                i += nbr * sizeof(float);
            } else {
                i += nbr * (vartbl[var].size + 1);
            }    
        } else 
            if(vartbl[var].type & T_STR) {
                i += STRINGSIZE;
            }    
    }
    
    vim = 0;
    
    CurrentRAM -= vim;
    pm = (PSize + 512)/1024;        pp = ((PSize + 512) * 100)/(CurrentRAM);        if(pm == 0) pp = 0;
    vm = (vsize + i + 512)/1024;    vp = ((vsize + i + 512) * 100)/CurrentRAM;      if(vm == 0) vp = 0;
    i = UsedHeap() - i;
    gm = ((i - vim + 512)/1024);    gp = ((i - vim + 512) * 100)/CurrentRAM;        if(gm == 0) gp = 0;
    if(pp + vp + gp > 100) gp = 100 - (pp + vp);
    
    // count the number of lines in the program
    p = PMemory;
    i = 0;
	while(1) {
		while(*p) p++;												// look for the zero marking the start of an element
		if(p[1] == 0) break;                                        // end of the program
		if(p[1] == T_LINENBR) {
    		i++;
    		p += 3;                                                 // skip over the line number
        }  		
		p++;
		skipspace(p);
		if(p[0] == T_LABEL) {
			p += p[1] + 2;											// skip over the label
		}	
    }
    
	sprintf(inpbuf, "%5dkB (%2d%%) Program (%d line%s)\r\n",  pm , pp, i, (i == 1 ? "" : "s")); 
	MMPrintString(inpbuf);
	sprintf(inpbuf, "%5dkB (%2d%%) %d Variable%s\r\n", vm , vp, vcnt, (vcnt == 1 ? "" : "s")); 
	MMPrintString(inpbuf);
	sprintf(inpbuf, "%5dkB (%2d%%) General\r\n", gm , gp); 
	MMPrintString(inpbuf);
	sprintf(inpbuf, "%5dkB (%2d%%) Free\r\n", (CurrentRAM + 512)/1024 - pm - vm - gm, 100 - pp - vp - gp); 
	MMPrintString(inpbuf);

#ifdef __DEBUG
	dp("\r\nStatic Variables = %p   Size = %dKB", RAMSTART, ((unsigned int)&_heap - RAMSTART)/1024);
	dp("        C32 Heap = %p   Size = %d bytes", (unsigned char *)&_heap, (unsigned int)&_splim - (unsigned int)&_heap);
	dp("  Program Memory = %p   Size = %dKB", PMemory, pm);
	dp("  Variable Table = %p   Size = %dKB", vartbl, (varcnt * (unsigned int)sizeof(struct s_vartbl))/1024);
	dp("         MM Heap = %p   Size = %dKB", (unsigned char *)MRoundUp((unsigned int)&vartbl[varcnt]), ((unsigned int)&_stack - (unsigned int)&_min_stack_size - PAGESIZE - MRoundUp((unsigned int)&vartbl[varcnt]))/1024);
	heapstats("                  ");
	dp("     STM32 Stack = %p   Size = %dKB  top = %p", (unsigned char *)&_stack - (unsigned int)&_min_stack_size - PAGESIZE, (unsigned int)&_min_stack_size/1024, (unsigned char *)&_stack);
#endif
	
}



/***********************************************************************************************************************
 Public memory management functions
************************************************************************************************************************/

/* all memory allocation (except for the heap) is made by m_alloc() 

   memory layout when a program is running:
   
          |--------------------|    <<<   TOP OF THE STACK   (unsigned char *)&_stack
          | Stack (grows down) |
          |--------------------|    <<<   (unsigned char *)&_stack - (unsigned int)&_min_stack_size
          |                    |          This is the top of the free RAM space
          |    MMBasic Heap    |
          |    (grows down)    |
          |                    |
          |--------------------|   <<<   VarTableTop
          |   Variable Table   |
          |     (grows up)     |
          |--------------------|   <<<   vartbl
          |                    |
          |   Program Memory   |
          |     (grows up)     |
          |                    |
          |--------------------|   <<<   PMemory
          |                    |
          |                    |
          |    Video Buffer    |
          | (fixed allocation) |
          |                    |
          |                    |
          |--------------------|   <<<   VideoBuf or VideoBufRed in the colour version
                                         This is the start of the free RAM space ((unsigned char *)&_splim)


   memory layout when the full screen editor is used:
   
          |--------------------|    <<<   TOP OF THE STACK   (unsigned char *)&_stack
          | Stack (grows down) |
          |--------------------|    <<<   (unsigned char *)&_stack - (unsigned int)&_min_stack_size
          |                    |          This is the top of the free RAM space
          |    Editor Memory   |                 ^
          | (fixed allocation, |                 |
          |  half free memory) |                 |
          |                    |                 |
          |--------------------|            free memory
          |                    |                 |
          |   Program Memory   |                 |
          | (fixed allocation, |                 |
          |  half free memory) |                 |
          |                    |                 v
          |--------------------|   <<<   PMemory
          |                    |
          |                    |
          |    Video Buffer    |
          | (fixed allocation) |
          |                    |
          |                    |
          |--------------------|   <<<   VideoBuf or VideoBufRed in the colour version
                                         This is the start of the free RAM space ((unsigned char *)&_splim)



  Calls are made to m_alloc() to assign the various pointers (VideoBuf, PMemory, etc)
  These calls must be made in this sequence:
        m_alloc(M_VIDEO, size)      Called once in main()
        m_alloc(M_PROG, size)       Called whenever program memory size changes
        m_alloc(M_EDIT, true)       Called whenever the editor is invoked
        m_alloc(M_EDIT, false)      Called when the editor terminates
        m_alloc(M_VAR, size)        Called when the program is running and whenever the variable table needs to be expanded
        
   Separately calls are made to getmemory() and FreeHeap() to allocate or free space on the heap (which grows downward 
   towards the variable table).  While the program is running an out of memory situation will occur when the space between 
   the heap (growing downwards) and the variable table (growing up) reaches zero.
   
*/

void m_alloc(int type, int size) {
    int t;
    static unsigned int VideoBufSize;
    switch(type) {
        case M_VIDEO:   // this allocates memory for the video buffer
                        // it is called once in main() to initialise the base pointer for the video buffer

                        break;

        case M_PROG:    // this initialises the pointer to the program memory (PMemory) and allocates space for the program
                        // it is called initially in InitBasic() to set the base pointer for program memory
                        // everytime the program size is adjusted up or down this must be called to check for memory overflow
                        PMemory = (unsigned char *)RAMSTART;
                        t = ((unsigned int)&_stack - (unsigned int)&_min_stack_size) - (unsigned int)PMemory - 1024;
                        if(size + 4 >= t) error("Not enough memory");
                        break;

        case M_EDIT:    // this initialises the pointer to the editor memory (EdBuff) and allocates space for the editor
                        // it must be called when the editor is invoked with the argument of true (1).  It splits the memory 50/50 between program and editor
                        // when the editor is finished this must be called with the argument of false (0) to release the memory used by the editor

            			if(size == 0)
            				EdBuff = NULL;
            			else {
            				t = ((unsigned int)&_stack - (unsigned int)&_min_stack_size) - (unsigned int)PMemory - 1024;
            				if(MRoundUp(PSize + 4) > t/2) error("Not enough memory");
            				EdBuff = PMemory + t/2;
            				EdBuffSize = t/2;
            			}
            			break;

        case M_VAR:     // this initialises the pointer to the variable memory table (vartbl) and allocates space for the table
                        // it must only be called after a call to M_PROG (which initialises the program memory pointer)
                        // everytime the variable table is increased this must be called to verify that enough memory is free
                        vartbl = (struct s_vartbl *)(PMemory + MRoundUp(PSize + 4));
                        VarTableTop = (unsigned char *)vartbl + MRoundUp(size);
                        if(MBitsGet(VarTableTop) & PUSED) {
                            TempStringClearStart = 0;
                            ClearTempSpace();                       // hopefully this will give us enough memory to print the prompt
                            error("Not enough memory");
                        }
                        break;
    }
}




// get some memory from the heap
void *getmemory(size_t msize) {
    TestStackOverflow();                                            // throw an error if we have overflowed the PIC32's stack
    return getheap(msize);                                          // allocate space
}


// Get a temporary buffer of any size
// The space only lasts for the length of the command.
// A pointer to the space is saved in an array so that it can be returned at the end of the command
void *GetTempSpace(int NbrBytes) {
    int i;
    for(i = 0; i < MAXTEMPSTRINGS; i++)
        if(strtmp[i] == NULL)
            return (strtmp[i] = getmemory(NbrBytes));
    error("Too many string expressions");
    return NULL;
}



// get a temporary string buffer
// this is used by many BASIC string functions.  The space only lasts for the length of the command.
void *GetTempStringSpace(void) {
    return GetTempSpace(STRINGSIZE);
}



// clear any temporary string spaces (these last for just the life of a command) and return the memory to the heap
void ClearTempSpace(void) {
    int i;
    for(i = TempStringClearStart; i < MAXTEMPSTRINGS; i++) {
        if(strtmp[i] != NULL) {
            FreeHeap(strtmp[i]);
            strtmp[i] = NULL;
        }
    }
}
    


// test the stack for overflow
// this will probably be caused by a fault within MMBasic but it could also be
// caused by a very complex BASIC expression
inline void TestStackOverflow(void) {
#if !defined(STM32F7) // PIC
	register unsigned int msp asm("sp");
	if(msp < (unsigned int)&_stack - (unsigned int)&_min_stack_size)
		error("Stack overflow. Expression is too complex");
#else // STM32F746
	// ToDo : add function
#endif // STM32F746
}



void FreeHeap(void *addr) {
    int bits;
    
    // check the validity of addr.  This includes catching a NULL pointer
    if((unsigned char *)addr <= VarTableTop || (unsigned char *)addr > ((unsigned char *)&_stack - (unsigned int)&_min_stack_size -  PAGESIZE)) return;
    
    // clear the bits
    do {
        bits = MBitsGet(addr);
        MBitsSet(addr, 0);
        addr += PAGESIZE;
    } while(bits != (PUSED | PLAST));
}



void InitHeap(void) {
    int i;
    
    // clear the heap entirely
    for(i = 0; i < (MEMSIZE/PAGESIZE) / PAGESPERWORD; i++) mmap[i] = 0;
    for(i = 0; i < MAXTEMPSTRINGS; i++) strtmp[i] = NULL;
    MBitsSet((unsigned char *)&_stack - (unsigned int)&_min_stack_size, PUSED | PLAST);
}    




/***********************************************************************************************************************
 Private memory management functions
************************************************************************************************************************/


unsigned int MBitsGet(void *addr) {
    unsigned int i, *p;
    addr -= RAMSTART;
    p = &mmap[((unsigned int)addr/PAGESIZE) / PAGESPERWORD];        // point to the word in the memory map
    i = ((((unsigned int)addr/PAGESIZE)) & (PAGESPERWORD - 1)) * PAGEBITS; // get the position of the bits in the word
    return (*p >> i) & ((1 << PAGEBITS) -1);
}



void MBitsSet(void *addr, int bits) {
    unsigned int i, *p;
    addr -= RAMSTART;
    p = &mmap[((unsigned int)addr/PAGESIZE) / PAGESPERWORD];        // point to the word in the memory map
    i = ((((unsigned int)addr/PAGESIZE)) & (PAGESPERWORD - 1)) * PAGEBITS; // get the position of the bits in the word
    *p = (bits << i) | (*p & (~(((1 << PAGEBITS) -1) << i)));
}



void *getheap(int size) {
    unsigned int j, n;
    unsigned char *addr;
    j = n = (size + PAGESIZE - 1)/PAGESIZE;                         // nbr of pages rounded up
    for(addr = (unsigned char *)&_stack - (unsigned int)&_min_stack_size -  PAGESIZE; addr > VarTableTop; addr -= PAGESIZE) {
        if(!(MBitsGet(addr) & PUSED)) {
            if(--n == 0) {                                          // found a free slot
                j--;
                MBitsSet(addr + (j * PAGESIZE), PUSED | PLAST);     // show that this is used and the last in the chain of pages
                while(j--) MBitsSet(addr + (j * PAGESIZE), PUSED);  // set the other pages to show that they are used
                memset(addr, 0, size);                              // zero the memory
                return (void *)addr;
            }
        } else
            n = j;                                                  // not enough space here so reset our count
    }
    // out of memory
    TempStringClearStart = 0;
    ClearTempSpace();                                               // hopefully this will give us enough to print the prompt
    error("Not enough memory");
    return NULL;                                                    // keep the compiler happy
}    



int FreeSpaceOnHeap(void) {
    unsigned int nbr;
    unsigned char *addr;
    nbr = 0;
    for(addr = (unsigned char *)&_stack - (unsigned int)&_min_stack_size -  PAGESIZE; addr > VarTableTop; addr -= PAGESIZE)
        if(!(MBitsGet(addr) & PUSED)) nbr++;
    return nbr * PAGESIZE;
}    
    


unsigned int UsedHeap(void) {
    unsigned int nbr;
    unsigned char *addr;
    nbr = 0;
    for(addr = (unsigned char *)&_stack - (unsigned int)&_min_stack_size -  PAGESIZE; addr > VarTableTop; addr -= PAGESIZE)
        if(MBitsGet(addr) & PUSED) nbr++;
    return nbr * PAGESIZE;
}    



char *HeapBottom(void) {
    unsigned char *p;
    unsigned char *addr;
    
    for(p = addr = (unsigned char *)&_stack - (unsigned int)&_min_stack_size -  PAGESIZE; addr > VarTableTop; addr -= PAGESIZE)
        if(MBitsGet(addr) & PUSED) p = addr;
    return (char *)p;
}    



#ifdef __DEBUG
void heapstats(char *m1) {
    int blk, siz, fre, hol;
    unsigned char *addr;
    blk = siz = fre = hol = 0;
    for(addr = (unsigned char *)&_stack - (unsigned int)&_min_stack_size - PAGESIZE; addr >= VarTableTop; addr -= PAGESIZE) {
        if(MBitsGet((void *)addr) & PUSED)
            {siz++; hol = fre;}
        else
            fre++;
        if(MBitsGet((void *)addr) & PLAST)
            blk++;
    }        
    dp("%s allocations = %d (using %dKB)  holes = %dKB   free = %dKB", m1, blk, siz/4, hol/4, (fre - hol)/4);
}

#endif

