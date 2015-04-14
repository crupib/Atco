/****************************************************************/
/*Program: PARSE.C                                              */
/*Author:  B.              Crupi                                */
/*Platform: Windows Operating System(tested on XP)              */
/*Compiler: Visual Studio 2008)                                 */
/*Comment: Program to read in a sentence of words within a file */
/*         and parse them into seperate lines of words.         */
/****************************************************************/

#include <stdio.h>   /*All c program must have this*/
#include <stdlib.h>
#include <string.h>
#define bufsize 1024 /*A defined integer for our buffer size*/

int main(){          /*Program entry point*/
     FILE* fp;       /*Declare file pointer variable*/
     char buf[bufsize], *tok, fname[15];
     printf("Enter filename: ");
     scanf("%s",&fname);
     
     /*If file doesn't exist or filetype isn't allowed exit and*/
     /*error message & return (1) control to the OS*/
     if ((fp = fopen(fname,"rt")) == NULL){ 
             fprintf(stderr,"Error opening file: %s\n",fname);
             return 1;
      }
      
     printf("\n"); /*Newline effect*/
     
     /*Read into the buffer contents within thr file stream*/
     while(fgets(buf, bufsize, fp) != NULL)
	 {	 
         /*Here we tokenize our string and scan for " \n" characters*/
		 for(tok = strtok(buf," ");tok;tok=strtok(0," "))
		 {		
              char * pch;
              pch = strstr (tok,"\n");
			  if (pch != NULL)
			  {
				  *pch=',';
                  printf("%s\n",tok);
			  }
			  else
		    	  printf("%s,",tok);
         }         
     }/*Continue until EOF is encoutered*/
	 fclose(fp); /*Close file*/
     printf("\n");
     system("pause"); /*System delay function (windows)*/
     return 0; /*Executed without errors*/
}/*End main*/

