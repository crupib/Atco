/***********************************************************************************************************************
Maximite

timers.c

This module manages all memory allocation for MMBasic running on the Maximite.

Copyright 2011 - 2013 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

**************************************************************************************************************************

NOTE:
  In the PIC32 the following variables are set by the linker:

      (unsigned char *)&_stack         This is the virtual address of the top of the stack and unless some RAM functions are
                                       defined it is also the top of the RAM.  In this case its value is 0xA0020000.

      (unsigned char *)&_splim         This is the virtual address of the top of the heap and represents the start of free
                                       and unallocated memory.

      (unsigned char *)&_heap          This is the virtual address of the top of the memory allocated by the compiler (static
                                       variables, etc)

      (unsigned int)&_min_stack_size   This is the number of bytes allocated to the stack.  No run time checking is performed
                                       and this value is only used by the linker to warn if memory is over allocated.


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

#include <p32xxxx.h>
#include <plib.h>
#include <stdio.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

extern unsigned int _stack;
extern unsigned int _splim;
extern unsigned int _heap;
extern unsigned int _min_stack_size;
extern unsigned int _text_begin;


// memory parameters for this chip
// ===============================
// The following settings will allow MMBasic to use all the free memory on the PIC32.  If you need some RAM for
// other purposes you can declare the space needed as a static variable -or- allocate space to the heap (which
// will reduce the memory available to MMBasic) -or- change the definition of RAMEND.
// NOTE: MMBasic does not use the heap.  It has its own heap which is allocated out of its own memory space.

// The virtual address that MMBasic can start using memory.  This must be rounded up to PAGESIZE.
// MMBasic uses just over 5K for static variables so, in the simple case, RAMBASE could be set to 0xA001800.
// However, the PIC32 C compiler provides us with a convenient marker (see diagram above).
#define RAMBASE         MRoundUp((unsigned int)&_splim)

// The virtual address that marks the end of the RAM allocated to MMBasic.  This must be rounded up to PAGESIZE.
// This determines maximum amount of RAM that MMBasic can use for program, variables and the heap.
// MMBasic uses just over 5K of RAM for static variables and needs at least 4K for the stack (6K preferably).
// So, using a chip with 32KB, RAMALLOC could be set to RAMBASE + (22 * 1024).
// However, the PIC32 C compiler provides us with a convenient marker (see diagram above).
#define RAMEND          ((unsigned int)&_stack - (unsigned int)&_min_stack_size)

// The total amount of memory that MMBasic might use.  Used only to declare a static array to track memory use.
// Because this must be a constant and the array does not consume much RAM we set it to the largest possible size for the PIC32
#define MEMSIZE        120



// other (minor) memory management parameters
#define PAGESIZE        256                                         // the allocation granuality
#define PAGEBITS        2                                           // nbr of status bits per page of allocated memory, must be a power of 2

#define PUSED           0b01                                        // flag that indicates that the page is in use
#define PLAST           0b10                                        // flag to show that this is the last page in a single allocation

#define PAGESPERWORD    ((sizeof(unsigned int) * 8)/PAGEBITS)
#define MRoundUp(a)     (((a) + (PAGESIZE - 1)) & (~(PAGESIZE - 1)))// round up to the nearest page size

unsigned int mmap[((MEMSIZE *1024)/PAGESIZE) / PAGESPERWORD];
char *strtmp[MAXTEMPSTRINGS];                                       // used to track temporary string space on the heap

unsigned char *VarTableTop;

unsigned int MBitsGet(void *addr);
void MBitsSet(void *addr, int bits);
void *getheap(int size);
unsigned int UsedHeap(void);
void heapstats(char *m1);





/***********************************************************************************************************************
 MMBasic commands
************************************************************************************************************************/


void cmd_memory(void) {
    int i, j, var, nbr, vsize, vcnt;
    int pm, pp, vm, vp, gm, gp;
    unsigned int CurrentRAM;
    char *p;

    CurrentRAM = (unsigned int)RAMEND - (unsigned int)PMemory;

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
            if(vartbl[var].type & T_NBR)
                i += nbr * sizeof(float);
            else
                i += nbr * (vartbl[var].size + 1);
        } else
            if(vartbl[var].type & T_STR)
                i += STRINGSIZE;
    }

    pm = (PSize + 512)/1024;        pp = (PSize * 100)/CurrentRAM;
    vm = (vsize + i + 512)/1024;    vp = ((vsize + i) * 100)/CurrentRAM;
    i = UsedHeap() - i;
    gm = (i + 512)/1024; gp = (i * 100)/CurrentRAM;

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
	dp("\r\nStatic Variables = 0xa0000000   Size = %dKB", ((unsigned int)&_heap - 0xA0000000)/1024);
	dp("        C32 Heap = %p   Size = %d bytes", (unsigned char *)&_heap, (unsigned int)&_splim - (unsigned int)&_heap);
	dp("  Program Memory = %p   Size = %dKB", PMemory, PSize/1024);
	dp("  Variable Table = %p   Size = %dKB", vartbl, (varcnt * (unsigned int)sizeof(struct s_vartbl))/1024);
	dp("         MM Heap = %p   Size = %dKB", (unsigned char *)MRoundUp((unsigned int)&vartbl[varcnt]), (RAMEND - PAGESIZE - MRoundUp((unsigned int)&vartbl[varcnt]))/1024);
	heapstats("                  ");
	dp("     PIC32 Stack = %p   Size = %dKB  top = %p", (unsigned char *)RAMEND - PAGESIZE, ((unsigned int)&_min_stack_size + 512)/1024, (unsigned char *)&_stack);
#endif

}



/***********************************************************************************************************************
 Public memory management functions
************************************************************************************************************************/

/* all memory allocation (except for the heap) is made by m_alloc()
   memory layout used by MMBasic:

          |--------------------|    <<<   This is the end of the RAM allocated to MMBasic (defined as RAMEND)
          |                    |
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
                                         This is the start of the RAM allocated to MMBasic (defined as RAMBASE)

  Calls are made to m_alloc() to assign the various pointers (VideoBuf, PMemory, etc)
  These calls must be made in this sequence:
        m_alloc(M_PROG, size)       Called whenever program memory size changes
        m_alloc(M_VAR, size)        Called when the program is running and whenever the variable table needs to be expanded

   Separately calls are made to getmemory() and FreeHeap() to allocate or free space on the heap (which grows downward
   towards the variable table).  While the program is running an out of memory situation will occur when the space between
   the heap (growing downwards) and the variable table (growing up) reaches zero.

*/


void m_alloc(int type, int size) {
    int t;

    switch(type) {
        case M_PROG:    // this is called initially in InitBasic() to set the base pointer for program memory
                        // everytime the program size is adjusted up or down this must be called to check for memory overflow
                        PMemory = (unsigned char *)RAMBASE;
                        t = RAMEND - (unsigned int)PMemory - 1024;
                        if(size + 4 >= t) error("Not enough memory");
                        break;

        case M_VAR:     // this must only be called after a call to M_PROG (which initialises the program memory pointer)
                        // everytime the variable table is increased this must be called to verify that enough memory is free
                        vartbl = (struct s_vartbl *)(PMemory + MRoundUp(PSize));
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
	register unsigned int msp asm("sp");
	if(msp < (unsigned int)RAMEND)
		error("Stack overflow. Expression is too complex");
}



void FreeHeap(void *addr) {
    int bits;
 //   dp(" free = %p", addr);
    do {
        if(addr < (void *)RAMBASE || addr >= (void *)RAMEND) return;
        bits = MBitsGet(addr);
        MBitsSet(addr, 0);
        addr += PAGESIZE;
    } while(bits != (PUSED | PLAST));
}



void InitHeap(void) {
    int i;
    for(i = 0; i < ((MEMSIZE *1024)/PAGESIZE) / PAGESPERWORD; i++) mmap[i] = 0;
    for(i = 0; i < MAXTEMPSTRINGS; i++) strtmp[i] = NULL;
    MBitsSet((unsigned char *)RAMEND, PUSED | PLAST);
}




/***********************************************************************************************************************
 Private memory management functions
************************************************************************************************************************/


unsigned int MBitsGet(void *addr) {
    unsigned int i, *p;
    addr -= RAMBASE;
    p = &mmap[((unsigned int)addr/PAGESIZE) / PAGESPERWORD];        // point to the word in the memory map
    i = ((((unsigned int)addr/PAGESIZE)) & (PAGESPERWORD - 1)) * PAGEBITS; // get the position of the bits in the word
    return (*p >> i) & ((1 << PAGEBITS) -1);
}



void MBitsSet(void *addr, int bits) {
    unsigned int i, *p;
    addr -= RAMBASE;
    p = &mmap[((unsigned int)addr/PAGESIZE) / PAGESPERWORD];        // point to the word in the memory map
    i = ((((unsigned int)addr/PAGESIZE)) & (PAGESPERWORD - 1)) * PAGEBITS; // get the position of the bits in the word
    *p = (bits << i) | (*p & (~(((1 << PAGEBITS) -1) << i)));
}



void *getheap(int size) {
    unsigned int j, n;
    unsigned char *addr;
    j = n = (size + PAGESIZE - 1)/PAGESIZE;                         // nbr of pages rounded up
    for(addr = (unsigned char *)RAMEND -  PAGESIZE; addr > VarTableTop; addr -= PAGESIZE) {
        if(!(MBitsGet(addr) & PUSED)) {
            if(--n == 0) {                                          // found a free slot
                j--;
                MBitsSet(addr + (j * PAGESIZE), PUSED | PLAST);     // show that this is used and the last in the chain of pages
                while(j--) MBitsSet(addr + (j * PAGESIZE), PUSED);  // set the other pages to show that they are used
                memset(addr, 0, size);                              // zero the memory
 //               dp("alloc = %p (%d)", addr, size);
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
    for(addr = (unsigned char *)RAMEND -  PAGESIZE; addr > VarTableTop; addr -= PAGESIZE)
        if(!(MBitsGet(addr) & PUSED)) nbr++;
    return nbr * PAGESIZE;
}



unsigned int UsedHeap(void) {
    unsigned int nbr;
    unsigned char *addr;
    nbr = 0;
    for(addr = (unsigned char *)RAMEND -  PAGESIZE; addr > VarTableTop; addr -= PAGESIZE)
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
    for(addr = (unsigned char *)RAMEND - PAGESIZE; addr >= VarTableTop; addr -= PAGESIZE) {
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

