.//============================================================================
.// $RCSfile: t.class.instancedump.c,v $
.//
.// Notice:
.//
.// This document contains confidential and proprietary information and
.// property of Mentor Graphics Corp.  No part of this document may be
.// reproduced without the express written permission of Mentor Graphics Corp.
.//============================================================================
.//
.if ( te_sys.InstanceLoading )
/*
 * Dump instances in SQL format.
 */
void
${te_class.GeneratedName}_instancedumper( ${te_instance.handle} instance )
{
  ${te_class.GeneratedName} * self = (${te_class.GeneratedName} *) instance;
  printf( "INSERT INTO ${te_class.Key_Lett} VALUES ( ${te_class.attribute_format} );\n"${te_class.attribute_dump} );
}
.end if
