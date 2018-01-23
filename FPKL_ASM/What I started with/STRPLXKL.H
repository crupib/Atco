struct plot  {
	unsigned long iscale;	/**  horizontal scale factor (-640 to -2 or 1 to 8)  **/// 0
	int   ishift;		/**  vertical scale factor (-8 to 8)                 **///     4
	int   n;		/**  number of points to plot (2 to 640)             **///         6 
	int   nperstrip;	/**  plotted points per strip                        **///     8
	int   startpoint;	/**  first plotted point in strip (initialize to 0)  **///     a
	int   stripdel;		/**  first data point in strip (initialize to 0)     **///     c
	int   xoff;		/**  horizontal screen offset (0 to 798)             **///         e
	int   yoff;		/**  vertical screen offset (0 to 798)               **///         10
	int   lolim;		/**  lower absolute clipping limit (0 to 799)        **///     12 
	int   hilim;		/**  upper absolute clipping limit (0 to 799)        **///     14
	int   color;		/**  plot color (1 to 16)                            **///     16
	int   idel;		/**  where to begin plotting in buffer               **///         18
	int   irec;		/**  rectify switch (see FP_SP_RECTIFY_ in FP.H)     **///         1A 
	int   type;             /**  data type (see FP_SP_DATA_ in FP.H)             **/// 1C
	int   on;		/**  reserved                                        **///         1E
	unsigned long lastremainder; /**  internally used value (initialize to 0)    **/// 20
	char  trans[256];       /**  256 byte lookup table (created by attrib())     **/// 24
	char  table[640];                                                             //  124
	unsigned  newn[640];
	unsigned  newy[640];
	unsigned  oldn[640];
	unsigned  oldy[640];
};
