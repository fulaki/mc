.//============================================================================
.// $RCSfile: t.smt_sr.multi_oneany_astob1where.c,v $
.//
.// Notice:
.// (C) Copyright 1998-2013 Mentor Graphics Corporation
.//     All rights reserved.
.//
.// This document contains confidential and proprietary information and
.// property of Mentor Graphics Corp.  No part of this document may be
.// reproduced without the express written permission of Mentor Graphics Corp.
.//============================================================================
.assign b = b + "${ws}{${te_lnk.te_classGeneratedName} * selected = ${cast}${te_lnk.left}->${te_lnk.linkage};\n"
.assign b = b + "${ws}if ( ( 0 != selected ) && ${te_select_related.where_clause} ) {\n"
.assign b = b + "${ws}  ${te_select_related.result_var} = selected;\n"
.assign b = b + "${ws}}}\n"