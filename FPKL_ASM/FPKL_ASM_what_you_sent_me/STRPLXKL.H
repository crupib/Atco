struct plot  {
	unsigned long iscale;	/**  horizontal scale factor (-640 to -2 or 1 to 8)  **/
	int   ishift;		/**  vertical scale factor (-8 to 8)                 **/
	int   n;		/**  number of points to plot (2 to 640)             **/
	int   nperstrip;	/**  plotted points per strip                        **/
	int   startpoint;	/**  first plotted point in strip (initialize to 0)  **/
	int   stripdel;		/**  first data point in strip (initialize to 0)     **/
	int   xoff;		/**  horizontal screen offset (0 to 798)             **/
	int   yoff;		/**  vertical screen offset (0 to 798)               **/
	int   lolim;		/**  lower absolute clipping limit (0 to 799)        **/
	int   hilim;		/**  upper absolute clipping limit (0 to 799)        **/
	int   color;		/**  plot color (1 to 16)                            **/
	int   idel;		/**  where to begin plotting in buffer               **/
	int   irec;		/**  rectify switch (see FP_SP_RECTIFY_ in FP.H)     **/
	int   type;             /**  data type (see FP_SP_DATA_ in FP.H)             **/
	int   on;		/**  reserved                                        **/
	unsigned long lastremainder; /**  internally used value (initialize to 0)    **/
	char  trans[256];       /**  256 byte lookup table (created by attrib())     **/
	char  table[640];
	unsigned  newn[640];
	unsigned  newy[640];
	unsigned  oldn[640];
	unsigned  oldy[640];
};
