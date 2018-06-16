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
  
************************************************************************************************************************/



#define INCLUDE_FUNCTION_DEFINES

#include <stdio.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

// memory management parameters
#define PAGESIZE        256                                         // the allocation granuality
#define PAGEBITS        2                                           // nbr of status bits per page of allocated memory, must be a power of 2

#define PUSED           1                                           // flag that indicates that the page is in use
#define PLAST           2                                           // flag to show that this is the last page in a single allocation

#define PAGESPERWORD    ((sizeof(unsigned int) * 8)/PAGEBITS)

unsigned int mmap[(HEAP_SIZE/PAGESIZE) / PAGESPERWORD];
char *strtmp[MAXTEMPSTRINGS];                                       // used to track temporary string space on the heap

// allocate static memory for programs, variables and the heap
// this is simple memory management because DOS has plenty of memory
unsigned char DOS_PMemory[PMEMORY_SIZE];
unsigned char  DOS_vartbl[MAXVARS * sizeof(struct s_vartbl)];
unsigned char MMHeap[HEAP_SIZE];

unsigned int MBitsGet(unsigned char *addr);
void MBitsSet(unsigned char *addr, int bits);
void *getheap(int size);
unsigned int UsedHeap(void);





/***********************************************************************************************************************
 MMBasic commands
************************************************************************************************************************/


void cmd_memory(void) {
    int i, vcnt;
    int pm, pp, gm, gp;
    char *p;
    
    // calculate the number of variables
    for(i = vcnt = 0; i < varcnt; i++) {
        if(vartbl[i].type != T_NOTYPE) vcnt++;
    }
    
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
    
    pm = (PSize + 512)/1024;       pp = ((PSize + 512) * 100)/PMEMORY_SIZE;
    gm = (UsedHeap() + 512)/1024;  gp = ((UsedHeap() + 512) * 100)/HEAP_SIZE;
    
	sprintf(inpbuf, "%5d%% Program (%d line%s using %dKB of %dKB)\r\n" , pp, i, (i == 1 ? "" : "s"), pm, PMEMORY_SIZE/1024); 
	MMPrintString(inpbuf);
	sprintf(inpbuf, "%5d%% Array, strings and general (using %dKB of %dKB)\r\n", gp, gm, HEAP_SIZE/1024); 
	MMPrintString(inpbuf);
	sprintf(inpbuf, "%5d%% Variables (using %d of %d)\r\n", (vcnt * 100)/MAXVARS, vcnt, MAXVARS); 
	MMPrintString(inpbuf);

}



/***********************************************************************************************************************
 Public memory management functions
************************************************************************************************************************/

/* all memory allocation (except for the heap) is made by m_alloc() 
   memory layout is based on static allocation of RAM (very simple)
   see the Maximite version of MMBasic for a more complex dynamic memory management scheme
   
          |--------------------|
          |                    |
          |    MMBasic Heap    |
          |    (grows down)    |
          |                    |
          |--------------------|   <<<   MMHeap
          
          
          |--------------------|
          |   Variable Table   |
          |     (grows up)     |
          |--------------------|   <<<   vartbl and DOS_vartbl
          
          
          |--------------------|
          |                    |
          |   Program Memory   |
          |     (grows up)     |
          |                    |
          |--------------------|   <<<   PMemory and DOS_PMemory

  Calls are made to m_alloc() to assign the various pointers (PMemory, etc)
  These calls must be made in this sequence:
        m_alloc(M_PROG, size)       Called whenever program memory size changes
        m_alloc(M_VAR, size)        Called when the program is running and whenever the variable table needs to be expanded
        
   Separately calls are made to getmemory() and FreeHeap() to allocate or free space on the heap (which grows downward).
   
*/


void m_alloc(int type, int size) {
    switch(type) {
        case M_PROG:    // this is called initially in InitBasic() to set the base pointer for program memory
                        // everytime the program size is adjusted up or down this must be called to check for memory overflow
                        PMemory = DOS_PMemory;
                        if(size + 4 >= PMEMORY_SIZE) error("Not enough memory");
                        break;
                        
        case M_VAR:     // this must be called to initialises the variable memory pointer
                        // everytime the variable table is increased this must be called to verify that enough memory is free
                        vartbl = (struct s_vartbl *)DOS_vartbl;
                        if(size >= MAXVARS * sizeof(struct s_vartbl)) error("Not enough memory");
                        break;
    }
}



// get some memory from the heap
void *getmemory(size_t msize) {
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
    


// test the stack for overflow - this is a NULL function in the DOS version
void TestStackOverflow(void) {}



void FreeHeap(unsigned char *addr) {
    int bits;
    if(addr == NULL) return;
 //   dp(" free = %p", addr);
    do {
        bits = MBitsGet(addr);
        MBitsSet(addr, 0);
        addr += PAGESIZE;
    } while(bits != (PUSED | PLAST));
}



void InitHeap(void) {
    int i;
    for(i = 0; i < (HEAP_SIZE/PAGESIZE) / PAGESPERWORD; i++) mmap[i] = 0;
    for(i = 0; i < MAXTEMPSTRINGS; i++) strtmp[i] = NULL;
}    




/***********************************************************************************************************************
 Private memory management functions
************************************************************************************************************************/


unsigned int MBitsGet(unsigned char *addr) {
    unsigned int i, *p;
    addr -= (unsigned int)&MMHeap[0];
    p = &mmap[((unsigned int)addr/PAGESIZE) / PAGESPERWORD];        // point to the word in the memory map
    i = ((((unsigned int)addr/PAGESIZE)) & (PAGESPERWORD - 1)) * PAGEBITS; // get the position of the bits in the word
    return (*p >> i) & ((1 << PAGEBITS) -1);
}



void MBitsSet(unsigned char *addr, int bits) {
    unsigned int i, *p;
    addr -= (unsigned int)&MMHeap[0];
    p = &mmap[((unsigned int)addr/PAGESIZE) / PAGESPERWORD];        // point to the word in the memory map
    i = ((((unsigned int)addr/PAGESIZE)) & (PAGESPERWORD - 1)) * PAGEBITS; // get the position of the bits in the word
    *p = (bits << i) | (*p & (~(((1 << PAGEBITS) -1) << i)));
}



void *getheap(int size) {
    unsigned int j, n;
    unsigned char *addr;
    j = n = (size + PAGESIZE - 1)/PAGESIZE;                         // nbr of pages rounded up
    for(addr = MMHeap + HEAP_SIZE - PAGESIZE; addr >= MMHeap; addr -= PAGESIZE) {
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
    for(addr = MMHeap + HEAP_SIZE - PAGESIZE; addr >= MMHeap; addr -= PAGESIZE)
        if(!(MBitsGet(addr) & PUSED)) nbr++;
    return nbr * PAGESIZE;
}    
    


unsigned int UsedHeap(void) {
    unsigned int nbr;
    unsigned char *addr;
    nbr = 0;
    for(addr = MMHeap + HEAP_SIZE - PAGESIZE; addr >= MMHeap; addr -= PAGESIZE)
        if(MBitsGet(addr) & PUSED) nbr++;
    return nbr * PAGESIZE;
}    



char *HeapBottom(void) {
    unsigned char *p;
    unsigned char *addr;
    
    for(p = addr = MMHeap + HEAP_SIZE - PAGESIZE; addr > MMHeap; addr -= PAGESIZE)
        if(MBitsGet(addr) & PUSED) p = addr;
    return (char *)p;
}    



#ifdef __DEBUG
void heapstats(unsigned char *m1) {
    int blk, siz, fre, hol;
    unsigned char *addr;
    blk = siz = fre = hol = 0;
    for(addr = MMHeap + HEAP_SIZE - PAGESIZE; addr >= MMHeap; addr -= PAGESIZE) {
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

