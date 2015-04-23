// parse.cpp : Defines the entry point for the console application.
//
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
unsigned char mychar;
unsigned char cmd[20];
unsigned char command;
unsigned char address,headerbyte,controlbyte;
unsigned char chksum;
int i, len;
unsigned char position[20];
int parsecmd(unsigned char *  cmd);
int numberbytes;
int main(void)
{
	   i = 0;
	   memset(cmd,'\0',20);
	   memset(position,'\0',20);
	   cmd[0] = 0xaa;
	   cmd[1] = 0x01;
	   cmd[2] = 0x50;
	   cmd[3] = 0x02;
	   cmd[4] = 0xA2;
	   cmd[5] = 0x32;
	   cmd[6] = 0x54;
	   cmd[7] = 0x01;
	   cmd[8] = 0x7c;
       for ( i = 0; i < 19; i++)
	   {
		   if (!cmd[i])
			   break;
	   }
	   len = i;

	   headerbyte = cmd[0];
	   address = cmd[1];
	   chksum = 0;

	   numberbytes = (cmd[2]&0xF0)>>4;
	   command = (cmd[2]&0x0F);
       
	   for(i=1; i < (numberbytes+3);i++)
		   chksum += cmd[i];
	   chksum = chksum & 255;	
       printf("%x\n",headerbyte);
	   printf("%x\n",address);
	   printf("%x\n",command);
	   printf("%x\n",numberbytes);
	   printf("%x\n",chksum);
       i = 0;	   
//     while (1) {
         parsecmd(cmd);       
//     }
       return 0;
}
int parsecmd(unsigned char * cmd)
{
	   int k;
	   
       if ( cmd[0] == 0xaa) 
	   {
		   switch (command) {
			 case 0:
				 printf("Reset Position\n");
				 if (numberbytes>0)
					 controlbyte = cmd[3];

				 switch (controlbyte) {	
					   case 0x01:
						  printf("Reset relative to Home Position\n");
						  break;
					   case 0x02:
						  printf("Set postion counter to specific value\n");
						  k=4;
						  for (int j=0;j < numberbytes;j++)
						  {
							  position[j] = cmd[k++];
						  }
						  printf("Position data!\n");
						  for (i = 0;i< numberbytes-1 ;i++)
						  {							  
							  printf("%x\n",position[i]);
						  }
						  break;
					  default:
						   printf( "Bad Control byte\n");
				 }
                 break;
			 case 1:
                 printf("Set Address\n");

                 break;
			 case 2:
                 printf("Define Status\n");
                 break;
			 case 3:
                 printf("Read Status\n");
				 switch (controlbyte) {	
					  case 0x80:
						  printf("Send number of path points left in path point buffer\n");
						  break;
					  case 0x20:
						  printf("Send Device type and device version\n");
						  break;
					   case 0x10:
						  printf("Send Home Position\n");
						  break;
					   case 0x08:
						  printf("Send auxiliary status byte\n");
						  break;
					   case 0x04:
						  printf("Send actual velocity in encoder counts\n");
						  break;
					   case 0x02:
						  printf("Send A/D value of voltage\n");
						  break;
					   case 0x01:
						  printf("Send Position data (4 bytes signed 32 bit integer\n");
						  break;
					  default:
						   printf( "Bad Control byte\n");
				 }
                 break;
			 case 4:
                 printf("Load Trajectory\n");
                 break;
			 case 5:
                 printf("Start Motion\n");
                 break;
			 case 6:
                 printf("Set Gain\n");
                 break;
			 case 7:
                 printf("Stop Motor\n");
                 break;
			 case 8:
                 printf("I/O Control\n");
                 break;
			 case 9:
                 printf("Set Homing\n");
                 break;
			 case 10:
                 printf("Set Baud Rate\n");
                 break;
			 case 11:
                 printf("Clear Bits\n");
                 break;
			 case 12:
                 printf("Save as Home\n");
                 break;
			 case 13:
                 printf("Add Path Points\n");
                 break;
			 case 14:
                 printf("NoOp\n");
                 break;
			 case 15:
                 printf("Hard Reset\n");
                 break;
             default:
                 printf( "Bad command\n");
			 }
	   }
       return 0;
}
 