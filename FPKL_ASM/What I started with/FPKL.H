/*************************************************************************
/*
/*   FPKL.H header file for FastPlot KL library
/*   Copyright 1993 Sonix, Inc.
/*
/************************************************************************/




/******************/
/**              **/
/**  Prototypes  **/
/**              **/
/******************/

void  fir( char *ibuff,  char *obuff,  int buflen,  int rectify,
           int *weights,  int numweights,  int divisor );

void  four1( float *data,  int nn,  int isign );

void  fp_video_filter( char *ibuff,  char *obuff,  int buflen,
                       unsigned filter );

void  power( char *buff,  int len,  float *ps,  int flen );
