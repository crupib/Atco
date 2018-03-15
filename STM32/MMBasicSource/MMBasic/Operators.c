/***********************************************************************************************************************
MMBasic

operators.c

Provides the operator functions used in MMBasic  Ie, +, -, *, etc.
  
Copyright 2011 - 2014 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following 
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

************************************************************************************************************************/

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"




/********************************************************************************************************************************************
 basic operators
 each function is responsible for decoding a basic operator
 all function names are in the form op_xxxx() so, if you want to search for the function responsible for the AND operator look for op_and
 
 There are 5 globals used by these finctions:
 
 farg1, farg2   These are the floating point arguments to the operator.  farg1 is the left argument
 
 sarg1, sarg2   These are the string pointers to the arguments for a the string operator.  sarg1 is the left argument
                
 fret           Is the return value for a basic operator that returns a float value
 
 sret           Is the return value for a basic operator that returns a string
                
 targ           Is the type of the arguments.  normally this is set by the caller and is not changed by the function

 ********************************************************************************************************************************************/




void op_invalid(void) {
	error("Syntax error");
}


void op_exp(void) {
	fret = (float)pow(farg1, farg2);
}


void op_mul(void) {
	fret = farg1 * farg2;
}


void op_div(void) {
	if(farg2 == 0) error("Divide by zero");
	fret = farg1 / farg2;
}


void op_divint(void) {
	int a, b;
	a = MMround(farg1);
	b = MMround(farg2);
	if(b == 0) error("Divide by zero");
	fret = (float)(a / b);
}


void op_add(void) {
	if(targ & T_NBR)
		fret = farg1 + farg2;
	else {
		if(*sarg1 + *sarg2 > MAXSTRLEN) error("String too long");
		sret = GetTempStringSpace();								// this will last for the life of the command
		Mstrcpy(sret, sarg1);
		Mstrcat(sret, sarg2);
	}
}



void op_subtract(void) {
	fret = farg1 - farg2;
}


void op_mod(void) {
	int a, b;
	a = MMround(farg1);
	b = MMround(farg2);
	if(b == 0) error("Divide by zero");
	fret = (float)(a % b);
}


void op_ne(void) {
	if(targ & T_NBR)
		fret = (float)((farg1 != farg2) ? 1 : 0);
	else 
		fret = (float)((Mstrcmp(sarg1, sarg2) != 0) ? 1 : 0);
	targ = T_NBR;									// always return a number, even if the args are string
}



void op_gte(void) {
	if(targ & T_NBR)
		fret = (float)((farg1 >= farg2) ? 1 : 0);
	else
		fret = (float)((Mstrcmp(sarg1, sarg2) >= 0) ? 1 : 0);
	targ = T_NBR;									// always return a number, even if the args are string
}


void op_lte(void) {
	if(targ & T_NBR)
		fret = (float)((farg1 <= farg2) ? 1 : 0);
	else
		fret = (float)((Mstrcmp(sarg1, sarg2) <= 0) ? 1 : 0);
	targ = T_NBR;									// always return a number, even if the args are string
}


void op_lt(void) {
	if(targ & T_NBR)
		fret = (float)((farg1 < farg2) ? 1 : 0);
	else
		fret = (float)((Mstrcmp(sarg1, sarg2) < 0) ? 1 : 0);
	targ = T_NBR;									// always return a number, even if the args are string
}


void op_gt(void) {
	if(targ & T_NBR)
		fret = (float)((farg1 > farg2) ? 1 : 0);
	else
		fret = (float)((Mstrcmp(sarg1, sarg2) > 0) ? 1 : 0);
	targ = T_NBR;									// always return a number, even if the args are string
}


void op_equal(void) {
	if(targ & T_NBR)
		fret = (float)((farg1 == farg2) ? 1 : 0);
	else
		fret = (float)((Mstrcmp(sarg1, sarg2) == 0) ? 1 : 0);
	targ = T_NBR;									// always return a number, even if the args are string
}


void op_and(void) {
	int a, b;
	a = MMround(farg1);
	b = MMround(farg2);
	fret = (float)(a & b);
}


void op_or(void) {
	int a, b;
	a = MMround(farg1);
	b = MMround(farg2);
	fret = (float)(a | b);
}


void op_xor(void) {
	int a, b;
	a = MMround(farg1);
	b = MMround(farg2);
	fret = (float)(a ^ b);
}


void op_not(void){
	// don't do anything, just a place holder
	error("Syntax error");
}

