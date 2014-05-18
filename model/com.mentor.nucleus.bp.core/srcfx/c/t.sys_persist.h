T_b("/*---------------------------------------------------------------------");
T_b("\n");
T_b(" ");
T_b("* File:  ");
T_b(te_file->persist);
T_b(".");
T_b(te_file->hdr_file_ext);
T_b("\n");
T_b(" ");
T_b("*");
T_b("\n");
T_b(" ");
T_b("* Description:");
T_b("\n");
T_b(" ");
T_b("* This file provides persistence mechanisms to maintain instances and");
T_b("\n");
T_b(" ");
T_b("* associations across power and reset cycles.");
T_b("\n");
T_b(" ");
T_b("*");
T_b("\n");
T_b(" ");
T_b("* ");
T_b(te_copyright->body);
T_b("\n");
T_b(" ");
T_b("*-------------------------------------------------------------------*/");
T_b("\n");
T_b("#ifndef ");
T_b(te_prefix->define_u);
T_b(te_file->persist);
T_b("_");
T_b(te_file->hdr_file_ext);
T_b("\n");
T_b("#define ");
T_b(te_prefix->define_u);
T_b(te_file->persist);
T_b("_");
T_b(te_file->hdr_file_ext);
T_b("\n");
T_b(te_target->c2cplusplus_linkage_begin);
T_b("\n");
T_b(persist_check_mark->type);
T_b(" ");
T_b(persist_check_mark->name);
T_b("(");
T_b("\n");
T_b(persist_check_mark->arglist_types);
T_b(" );");
T_b("\n");
T_b(persist_post_link->type);
T_b(" ");
T_b(persist_post_link->name);
T_b("(");
T_b("\n");
T_b(persist_post_link->arglist_types);
T_b(" );");
T_b("\n");
T_b("void ");
T_b(te_persist->remove);
T_b("(");
T_b("\n");
T_b("  ");
T_b("const ");
T_b(te_instance->handle);
T_b(",");
T_b("\n");
T_b("  ");
T_b("const ");
T_b(te_typemap->domain_number_name);
T_b(",");
T_b("\n");
T_b("  ");
T_b("const ");
T_b(te_typemap->object_number_name);
T_b(" );");
T_b("\n");
T_b("i_t ");
T_b(te_persist->commit);
T_b("( void );");
T_b("\n");
T_b("i_t ");
T_b(te_persist->restore);
T_b("( void );");
T_b("\n");
T_b("void ");
T_b(te_persist->factory_init);
T_b("( void );");
T_b("\n");
T_b(te_target->c2cplusplus_linkage_end);
T_b("\n");
T_b("#endif  /* ");
T_b(te_prefix->define_u);
T_b(te_file->persist);
T_b("_");
T_b(te_file->hdr_file_ext);
T_b(" */");
T_b("\n");