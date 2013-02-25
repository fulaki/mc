.//============================================================================
.// $RCSfile: q.class.link.arc,v $
.//
.// Description:
.// This archetype file contains the functions for generating class
.// association link methods and member data implementation code.
.//
.// Notice:
.// (C) Copyright 1998-2013 Mentor Graphics Corporation
.//     All rights reserved.
.//
.// This document contains confidential and proprietary information and
.// property of Mentor Graphics Corp.  No part of this document may be
.// reproduced without the express written permission of Mentor Graphics Corp.
.//============================================================================
.//
.//============================================================================
.// This function provides the first level of translation indirection for
.// implementation of relationships for a given application analysis object.
.// For each relationship in which the object participates, invoke processing
.// algorithm centric to the specific relationship type.
.//============================================================================
.function RenderObjectRelationships
  .param inst_ref o_obj
  .param boolean  gen_declaration
  .//
  .select any te_instance from instances of TE_INSTANCE
  .select many te_rels related by o_obj->R_OIR[R201]->R_REL[R201]->TE_REL[R2034]
  .//
  .// Create an instance on which the relationship data storage components
  .// will be propagated.
  .create object instance te_relstore of TE_RELSTORE
  .assign te_relstore.link_index = 0
  .assign te_relstore.self_name = te_instance.self
  .//
  .if ( not_empty te_rels )
    .// Pre-order the relationships ascending by their relationship number.
    .// Note:  Decouples code gen from SQL table insertion ordering internals.
    .invoke SortSetAscendingByAttr_Numb( te_rels )
    .assign rel_count = 0
    .assign rel_cardinality = cardinality te_rels
    .// Allocate a fragment for the link calls and propogate it.
    .//
    .while ( rel_count < rel_cardinality )
      .for each te_rel in te_rels
        .select one rel related by te_rel->R_REL[R2034]
        .if ( te_rel.Order == rel_count )
          .// Simple relationship?
          .select one simple_rel related by rel->R_SIMP[R206]
          .if ( not_empty simple_rel )
            .invoke methods = SimpleRelationshipMethods( o_obj, rel, te_relstore, gen_declaration )
${methods.body}\
          .else
            .// Subtype-Supertype relationship?
            .select one subtype_supertype_rel related by rel->R_SUBSUP[R206]
            .if ( not_empty subtype_supertype_rel )
              .invoke methods = SubSuperRelationshipMethods( o_obj, rel, te_relstore, gen_declaration )
${methods.body}\
          .else
            .// Associative relationship?
            .select one associative_rel related by rel->R_ASSOC[R206]
            .if ( not_empty associative_rel )
              .invoke methods = AssociativeRelationshipMethods( o_obj, rel, te_relstore, gen_declaration )
${methods.body}\
          .else
            .// Composed relationship?
            .select one composed_rel related by rel->R_COMP[R206]
            .if ( not_empty composed_rel )
              .invoke methods = ComposedRelationshipMethods( o_obj, rel, te_relstore, gen_declaration )
${methods.body}\
          .else
            .// Error:  New subtype of R_REL or a corrupted model SQL...
            .print "ERROR:  Unknown association type:R${rel.Numb} for class ${o_obj.Name} (${o_obj.Name})"
            .exit 101
          .end if  .// not_empty composed_rel
          .end if  .// not_empty associative_rel
          .end if  .// not_empty subtype_supertype_rel
          .end if  .// not_empty simp_rel
          .//
          .break for  .// rel in rel_set
        .end if  .// rel.Order == rel_count
      .end for  .// rel in rel_set
      .//
      .assign rel_count = rel_count + 1
    .end while .// rel_count < rel_cardinality
    .invoke persist_link_function = PersistLinkFunction( te_relstore, o_obj, gen_declaration )
${persist_link_function.body}\
  .end if  .// not_empty rel_set
  .//
  .// Propagate the relationship data storage component fragments as
  .// an output fragment attribute of this function.
  .assign attr_result = te_relstore
  .//
.end function
.//
.//============================================================================
.// Generate code for simple relationships (one to one, one to many with
.// no associator).  This includes simple reflexives.
.//============================================================================
.function SimpleRelationshipMethods
  .param inst_ref o_obj
  .param inst_ref r_rel
  .param inst_ref te_relstore
  .param boolean  gen_declaration
  .//
  .select one simple_rel related by r_rel->R_SIMP[R206]
  .select one formalizer related by simple_rel->R_FORM[R208]
  .select one participant related by simple_rel->R_PART[R207]
  .//
  .select one rto related by participant->R_RTO[R204]
  .select one rgo related by formalizer->R_RGO[R205]
  .//
  .invoke r = CreateRelInfoFragment( o_obj, o_obj, r_rel, rto, rgo )
  .assign rel_info = r.rel_info
  .assign rel_info.gen_declaration = gen_declaration
  .//
  .if ( participant.Obj_ID != formalizer.Obj_ID )
    .//
    .if ( o_obj.Obj_ID == participant.Obj_ID )
      .// object as Simple Participant, get formalizing object.
      .select one related_obj related by formalizer->R_RGO[R205]->R_OIR[R203]->O_OBJ[R201]
      .assign rel_info.related_obj = related_obj
      .assign rel_info.multiplicity = formalizer.Mult
      .assign rel_info.is_formalizer = FALSE
      .select one oir related by rto->R_OIR[R203]
      .assign rel_info.oir = oir
    .else
      .// object as Simple Formalizer, get participant object.
      .select one related_obj related by rto->R_OIR[R203]->O_OBJ[R201]
      .assign rel_info.related_obj = related_obj
      .assign rel_info.multiplicity = participant.Mult
      .assign rel_info.is_formalizer = TRUE
      .select one oir related by rgo->R_OIR[R203]
      .assign rel_info.oir = oir
      .//
      .invoke links = CreateSimpleFormalizerMethods( te_relstore, o_obj, r_rel, gen_declaration )
${links.body}\
      .//
    .end if
    .//
    .invoke methods = ImplementRelationshipFundamentals( rel_info, te_relstore )
${methods.body}\
    .//
  .else
    .// reflexive simple relationship
    .if ( gen_declaration )
      .invoke part_mc = GetMultCondString( participant.Mult, participant.Cond )
      .invoke form_mc = GetMultCondString( formalizer.Mult, formalizer.Cond )
      
/*
 * R${r_rel.Numb} is Simple Reflexive:  ${part_mc.result}:${form_mc.result}
      .// Check for OOA96 compliance
      .if ( participant.Mult != formalizer.Mult )
 * Note:  Reflexive association is asymmetric.
      .end if
 *  Formalizing ${o_obj.Key_Lett} ${participant.Txt_Phrs} participant
 *  Participant ${o_obj.Key_Lett} ${formalizer.Txt_Phrs} formalizer
 */
    .end if  .// gen_declaration
    .//
    .// Handle participant side
    .assign rel_info.multiplicity = participant.Mult
    .assign rel_info.rel_phrase = participant.Txt_Phrs
    .assign rel_info.is_formalizer = FALSE
    .invoke part_links = CreateSimpleReflexiveFormalizerMethods( te_relstore, o_obj, r_rel, participant.Txt_Phrs, gen_declaration )
    .invoke part_fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
    .//
    .// Handle formalizer side
    .assign rel_info.multiplicity = formalizer.Mult
    .assign rel_info.rel_phrase = formalizer.Txt_Phrs
    .assign rel_info.is_formalizer = TRUE
    .invoke form_links = CreateSimpleReflexiveFormalizerMethods( te_relstore, o_obj, r_rel, formalizer.Txt_Phrs, gen_declaration )
    .invoke form_fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
    .//
${part_links.body}\
${form_links.body}\
${part_fundamentals.body}\
${form_fundamentals.body}\
    .//
  .end if  .// participant.Obj_ID != formalizer.Obj_ID
.end function
.//
.//============================================================================
.// Build subtype/supertype accessors.
.//============================================================================
.function SubSuperRelationshipMethods
  .param inst_ref o_obj
  .param inst_ref r_rel
  .param inst_ref te_relstore
  .param boolean  gen_declaration
  .//
  .select one supertype related by r_rel->R_SUBSUP[R206]->R_SUPER[R212]
  .select one rto related by supertype->R_RTO[R204]
  .select any rgo related by r_rel->R_SUBSUP[R206]->R_SUB[R213]->R_RGO[R205]
  .//
  .invoke r = CreateRelInfoFragment( o_obj, o_obj, r_rel, rto, rgo )
  .assign rel_info = r.rel_info
  .assign rel_info.gen_declaration = gen_declaration
  .//
  .if ( o_obj.Obj_ID == supertype.Obj_ID )
    .// object as supertype in relationship.
    .assign rel_info.is_supertype = TRUE
    .assign rel_info.generate_subtype = TRUE
    .assign rel_info.is_formalizer = FALSE
    .select one oir related by rto->R_OIR[R203]
    .assign rel_info.oir = oir
    .select many subtype_set related by r_rel->R_SUBSUP[R206]->R_SUB[R213]
    .assign blurped_comment = FALSE
    .for each subtype in subtype_set
      .select one rgo related by subtype->R_RGO[R205]
      .select one sub_obj related by subtype->R_RGO[R205]->R_OIR[R203]->O_OBJ[R201]
      .assign rel_info.related_obj = sub_obj
      .assign rel_info.rgo = rgo
      .invoke methods = ImplementRelationshipFundamentals( rel_info, te_relstore )
      .if ( not blurped_comment )

/* Accessors to ${o_obj.Key_Lett}[R${r_rel.Numb}] subtypes */
        .assign blurped_comment = TRUE
      .end if
${methods.body}\
    .end for

  .else
    .// object as subtype in relationship
    .select any rgo related by r_rel->R_SUBSUP[R206]->R_SUB[R213]->R_RGO[R205] where ( selected.Obj_ID == o_obj.Obj_ID )
    .select one supertype_obj related by supertype->R_RTO[R204]->R_OIR[R203]->O_OBJ[R201]
    .assign rel_info.rgo = rgo
    .assign rel_info.related_obj = supertype_obj
    .assign rel_info.is_formalizer = TRUE
    .select one oir related by rgo->R_OIR[R203]
    .assign rel_info.oir = oir
    .invoke AddRelationshipStorage( rel_info, te_relstore )
    .invoke methods = CreateSubtypeFormalizerMethods( te_relstore, o_obj, r_rel, gen_declaration )
${methods.body}\
  .end if
.end function
.//
.//============================================================================
.// Build up code gen info for associatives.
.//============================================================================
.function AssociativeRelationshipMethods
  .param inst_ref o_obj
  .param inst_ref r_rel
  .param inst_ref te_relstore
  .param boolean  gen_declaration
  .//
  .select one aone related by r_rel->R_ASSOC[R206]->R_AONE[R209]
  .select one aoth related by r_rel->R_ASSOC[R206]->R_AOTH[R210]
  .select one assr related by r_rel->R_ASSOC[R206]->R_ASSR[R211]
  .//
  .select one aone_rto related by aone->R_RTO[R204]
  .select one aoth_rto related by aoth->R_RTO[R204]
  .select one assr_rgo related by assr->R_RGO[R205]
  .//
  .select one aone_oir related by aone_rto->R_OIR[R203]
  .select one aoth_oir related by aoth_rto->R_OIR[R203]
  .select one assr_oir related by assr_rgo->R_OIR[R203]
  .//
  .select one aone_obj related by aone_oir->O_OBJ[R201]
  .select one aoth_obj related by aoth_oir->O_OBJ[R201]
  .select one assr_obj related by assr_oir->O_OBJ[R201]
  .//
  .select one aone_te_class related by aone_obj->TE_CLASS[R2019]
  .select one aoth_te_class related by aoth_obj->TE_CLASS[R2019]
  .select one assr_te_class related by assr_obj->TE_CLASS[R2019]
  .//
  .// NOTE:  For now, we do not / cannot optimize out data based on navigation use.
  .//        Punch in as NavigatedTo to assure functional code...
  .//        ...unless dealing with a class that is discluded from gen.
  .if ( not aone_te_class.ExcludeFromGen )
    .select one te_nav related by aone_oir->TE_NAV[R2035]
    .assign te_nav.NavigatedTo = TRUE
  .end if
  .if ( not aoth_te_class.ExcludeFromGen )
    .select one te_nav related by aoth_oir->TE_NAV[R2035]
    .assign te_nav.NavigatedTo = TRUE
  .end if
  .if ( not assr_te_class.ExcludeFromGen )
    .select one te_nav related by assr_oir->TE_NAV[R2035]
    .assign te_nav.NavigatedTo = TRUE
  .end if
  .//
  .assign associative_reflexive = FALSE
  .if ( aone.Obj_Id == aoth.Obj_Id )
    .assign associative_reflexive = TRUE
  .end if
  .//
  .invoke r = CreateRelInfoFragment( o_obj, o_obj, r_rel, aone_rto, assr_rgo )
  .assign rel_info = r.rel_info
  .assign rel_info.gen_declaration = gen_declaration
  .//
  .if ( o_obj.Obj_ID == assr.Obj_ID )
    .// Associator object processing. e.g., Object As Associator (R_ASSR)
    .assign rel_info.oir = assr_oir
    .if ( not associative_reflexive )
      .//
      .assign rel_info.multiplicity = 0
      .assign rel_info.is_formalizer = TRUE
      .invoke assr_methods = CreateAssociativeFormalizerMethods( te_relstore, r_rel, "", gen_declaration )
      .//
      .// Handle Object As Associated One Side (R_AONE)
      .assign rel_info.related_obj = aone_obj
      .assign rel_info.rto = aone_rto
      .invoke aone_fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
      .//
      .// Handle Object As Associated Other Side (R_AOTH)
      .assign rel_info.related_obj = aoth_obj
      .assign rel_info.rto = aoth_rto
      .invoke aoth_fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
      .//
${assr_methods.body}\
${aone_fundamentals.body}\
${aoth_fundamentals.body}\
      .//
    .else
      .// reflexive associative relationship
      .assign rel_info.multiplicity = 0
      .assign rel_info.is_formalizer = TRUE
      .//
      .if ( gen_declaration )
        .select one aone_oid related by aone->R_RTO[R204]->O_ID[R109]
        .select one aoth_oid related by aoth->R_RTO[R204]->O_ID[R109]
/*
        .if ( (not_empty aone_oid) and (not_empty aoth_oid) )
          .select many aone_ref_set related by aone->R_RTO[R204]->O_RTIDA[R110]->O_REF[R111]->O_RATTR[R108]->O_ATTR[R106]
          .select many aoth_ref_set related by aoth->R_RTO[R204]->O_RTIDA[R110]->O_REF[R111]->O_RATTR[R108]->O_ATTR[R106]
          .invoke one_mc = GetMultCondString( aone.Mult, aone.Cond )
          .invoke other_mc = GetMultCondString( aoth.Mult, aoth.Cond )

 * R${r_rel.Numb} is Associative Reflexive:  \
          .if ( assr.Mult == 0 )
1-(${one_mc.result}:${other_mc.result})
          .else
M-(${one_mc.result}:${other_mc.result})
          .end if
          .// Check for OOA96 compliance
          .if ( (aone.Mult != aoth.Mult) or (aone.Cond != aoth.Cond) )
 * Note:  Reflexive association is asymmetric!
          .end if
 *
          .for each aone_ref in aone_ref_set
            .select one one_ref_attr_obj related by aone_ref->O_OBJ[R102]
 *  Referential attribute ${one_ref_attr_obj.Name}.${aone_ref.Name}
 *    refers across R${r_rel.Numb} in the direction of ${aone.Txt_Phrs} (R_AONE)
          .end for
 *
          .for each aoth_ref in aoth_ref_set
            .select one other_ref_attr_obj related by aoth_ref->O_OBJ[R102]
 *  Referential attribute ${other_ref_attr_obj.Name}.${aoth_ref.Name}
 *    refers across R${r_rel.Numb} in the direction of ${aoth.Txt_Phrs} (R_AOTH)
          .end for
          .//
        .else
 * Note:  Relationship is not formalized!
        .end if  .// (not_empty aone_oid) and (not_empty aoth_oid)
 */
        .//
      .end if
      .//
      .// Here we distinguish between aone and aother for role symmetric
      .// reflexive relationships (where the relationship phrase is identical
      .// on both ends of the relationship).
      .// We will create only one set of methods when role symmetric.
      .invoke aone_methods = CreateAssociativeReflexiveFormalizerMethods( te_relstore, r_rel, aone.Txt_Phrs, gen_declaration, true )
${aone_methods.body}\
      .if ( aone.Txt_Phrs != aoth.Txt_Phrs )
        .invoke aoth_methods = CreateAssociativeReflexiveFormalizerMethods( te_relstore, r_rel, aoth.Txt_Phrs, gen_declaration, false )
${aoth_methods.body}\
      .end if
      .//
      .// Handle Object As Associated One Side (R_AONE)
      .// * Note the reversal of R_RTO here!
      .assign rel_info.related_obj = aone_obj
      .assign rel_info.rto = aoth_rto
      .assign rel_info.rel_phrase = aone.Txt_Phrs
      .invoke aone_fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
      .//
      .// Handle Object As Associated Other Side (R_AOTH)
      .// * Note the reversal of R_RTO here!
      .assign rel_info.related_obj = aoth_obj
      .assign rel_info.rto = aone_rto
      .assign rel_info.rel_phrase = aoth.Txt_Phrs
      .invoke aoth_fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
      .//
${aone_fundamentals.body}\
${aoth_fundamentals.body}\
      .//
    .end if  .// not associative_reflexive
    .//
  .else
    .// associated object processing
    .if ( not associative_reflexive )
      .assign rel_info.related_obj = assr_obj
      .//
      .if ( o_obj.Obj_ID == aone.Obj_ID )
        .// This object is Object As Associated One Side (R_AONE)
        .// NOTE:  Multiplicity is that of the Other Side
        .assign rel_info.oir = aone_oir
        .assign rel_info.rto = aone_rto
        .assign rel_info.multiplicity = aoth.Mult
        .invoke fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
${fundamentals.body}\
        .//
      .else
        .// This object is Object As Associated Other Side (R_AOTH)
        .// NOTE:  Multiplicity is that of the One Side
        .assign rel_info.oir = aoth_oir
        .assign rel_info.rto = aoth_rto
        .assign rel_info.multiplicity = aone.Mult
        .invoke fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
${fundamentals.body}\
        .//
      .end if  .// obj.Obj_ID == aone.Obj_ID
    .else
      .// reflexive associative relationship
      .assign rel_info.related_obj = assr_obj
      .//
      .// Handle One Side
      .assign rel_info.rel_phrase = aone.Txt_Phrs
      .assign rel_info.rto = aone_rto
      .assign rel_info.oir = aone_oir
      .assign rel_info.multiplicity = aone.Mult
      .invoke aone_fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
      .//
      .// Handle Other Side
      .assign rel_info.rel_phrase = aoth.Txt_Phrs
      .assign rel_info.rto = aoth_rto
      .assign rel_info.oir = aoth_oir
      .assign rel_info.multiplicity = aoth.Mult
      .invoke aoth_fundamentals = ImplementRelationshipFundamentals( rel_info, te_relstore )
      .//
${aone_fundamentals.body}\
${aoth_fundamentals.body}\
      .//
    .end if
  .end if  .// o_obj.Obj_ID == assr.Obj_ID
.end function
.//
.//============================================================================
.// In this architecture, we do not support direct navigation of composed
.// relationships.  In structural code generation, just issue a warning.
.// Fragment generation will terminate if navigation is attempted in the
.// action language.
.//============================================================================
.function ComposedRelationshipMethods
  .param inst_ref o_obj
  .param inst_ref r_rel
  .param inst_ref te_relstore
  .param boolean  gen_declaration
  .//
  .if ( gen_declaration )
    .select one comp related by r_rel->R_COMP[R206]
    .select one one_side related by comp->R_CONE[R214]
    .select one one_side_oir related by one_side->R_OIR[R203]
    .invoke one_mc = GetMultCondString( one_side.Mult, one_side.Cond )
    .select any one_obj from instances of O_OBJ where ( selected.Obj_ID == one_side_oir.Obj_ID )
    .select one other_side related by comp->R_COTH[R215]
    .select one other_side_oir related by other_side->R_OIR[R203]
    .invoke other_mc = GetMultCondString( other_side.Mult, other_side.Cond )
    .select any other_obj from instances of O_OBJ where ( selected.Obj_ID == other_side_oir.Obj_ID )
    .//
    .assign msg1 = "WARNING:  R${r_rel.Numb} is COMPOSITION - No code generated"
    .assign msg2 = "R${r_rel.Numb} = ${comp.Rel_Chn} is ${one_mc.result}:${other_mc.result} from (${one_obj.Key_Lett}) to (${other_obj.Key_Lett})"
    .print "\n  ${msg1}\n  ${msg2}"
/* ${msg1} */
/* ${msg2} */
  .end if
  .//
.end function
.//
.//
.//============================================================================
.// association formalizing object Link/Unlink functions:
.//============================================================================
.//
.//
.//============================================================================
.// This function creates the relationship link and unlink methods for a
.// simple (non-reflexive) relationship. 
.//============================================================================
.function CreateSimpleFormalizerMethods
  .param inst_ref te_relstore
  .param inst_ref o_obj
  .param inst_ref r_rel
  .param boolean  gen_declaration
  .//
  .select any te_file from instances of TE_FILE
  .select any te_set from instances of TE_SET
  .select any te_target from instances of TE_TARGET
  .select one te_rel related by r_rel->TE_REL[R2034]
  .select one form related by r_rel->R_SIMP[R206]->R_FORM[R208]
  .select one part related by r_rel->R_SIMP[R206]->R_PART[R207]
  .select one part_obj related by part->R_RTO[R204]->R_OIR[R203]->O_OBJ[R201]
  .//
  .select one rto related by part->R_RTO[R204]
  .select one rgo related by form->R_RGO[R205]
  .//
  .select one part_te_class related by part_obj->TE_CLASS[R2019]
  .select one form_te_class related by o_obj->TE_CLASS[R2019]
  .select one te_c related by form_te_class->TE_C[R2064]
  .//
  .invoke relate_method   = GetRelateToName( o_obj, r_rel, "" )
  .invoke unrelate_method = GetUnrelateFromName( o_obj, r_rel, "" )
  .//
  .select one te_nav related by rto->R_OIR[R203]->TE_NAV[R2035]
  .assign rto_NavigatedTo = te_nav.NavigatedTo
  .select one te_nav related by rgo->R_OIR[R203]->TE_NAV[R2035]
  .assign rgo_NavigatedTo = te_nav.NavigatedTo
  .if ( gen_declaration )
    .assign part_mult_cmt = "<-"
    .if ( part.Mult != 0 )
      .assign part_mult_cmt = "<<-"
    .end if
    .assign form_mult_cmt = "->"
    .if ( form.Mult != 0 )
      .assign form_mult_cmt = "->>"
    .end if
    .assign externstatic = "static "
    .assign thismodule = ", ${te_c.Name} *"
    .if ( "C" == te_target.language )
      .assign externstatic = ""
      .assign thismodule = ""
    .end if
    .include "${te_file.arc_path}/t.class.relate_simple.h"
  .else
    .assign thismodule = ", ${te_c.Name} * thismodule"
    .if ( "C" == te_target.language )
      .assign thismodule = ""
    .end if
    .invoke form_data_member = GetRelationshipDataMemberName( part_obj, r_rel, "" )
    .invoke part_data_member = GetRelationshipDataMemberName( o_obj, r_rel, "" )
    .assign link_call = "${relate_method.result}( (${part_te_class.GeneratedName} *) l, (${form_te_class.GeneratedName} *) r )"
    .select any assoc from instances of O_OBJ where ( false )
    .invoke PersistAddLinkCalls( o_obj, part_obj, assoc, te_relstore, link_call )
    .select any oref related by rgo->O_REF[R111]
    .assign set_referentials = ""
    .assign reset_referentials = ""
    .if ( not_empty oref )
      .invoke set_refs = SetReferentialAttributes( "part", "form", rto, rgo )
      .invoke reset_refs = ResetReferentialAttributes( "form", rgo )
      .assign set_referentials = set_refs.body
      .assign reset_referentials = reset_refs.body
    .end if  .// not_empty oid
    .select any assoc from instances of O_OBJ where ( false )
    .invoke persist_relate = PersistCallPostLink( "0", te_relstore, o_obj, part_obj, "part", o_obj, "form", assoc, "" )
    .invoke persist_unrelate = PersistCallPostLink( "1", te_relstore, o_obj, part_obj, "part", o_obj, "form", assoc, "" )
    .include "${te_file.arc_path}/t.class.relate_simple.c"
  .end if  .// gen_declaration
  .//
.end function
.//
.//============================================================================
.// This function creates the relationship link and unlink methods for a
.// simple reflexive relationship.
.//============================================================================
.function CreateSimpleReflexiveFormalizerMethods
  .param inst_ref te_relstore
  .param inst_ref o_obj
  .param inst_ref r_rel
  .param string   rel_phrase
  .param boolean  gen_declaration
  .//
  .select any te_file from instances of TE_FILE
  .select any te_set from instances of TE_SET
  .select any te_target from instances of TE_TARGET
  .select one te_rel related by r_rel->TE_REL[R2034]
  .select one form related by r_rel->R_SIMP[R206]->R_FORM[R208]
  .select one part related by r_rel->R_SIMP[R206]->R_PART[R207]
  .select one rto related by part->R_RTO[R204]
  .select one rgo related by form->R_RGO[R205]
  .select one te_class related by o_obj->TE_CLASS[R2019]
  .select one te_c related by te_class->TE_C[R2064]
  .//
  .invoke relate_method = GetRelateToName( o_obj, r_rel, rel_phrase )
  .invoke unrelate_method = GetUnrelateFromName( o_obj, r_rel, rel_phrase )
  .invoke part_data_member = GetRelationshipDataMemberName( o_obj, r_rel, part.Txt_Phrs )
  .invoke form_data_member = GetRelationshipDataMemberName( o_obj, r_rel, form.Txt_Phrs )
    .//
  .//
  .if ( gen_declaration )
    .assign externstatic = "static "
    .assign thismodule = ", ${te_c.Name} *"
    .if ( "C" == te_target.language )
      .assign externstatic = ""
      .assign thismodule = ""
    .end if
    .include "${te_file.arc_path}/t.class.relate_reflex.h"
  .else
    .assign thismodule = ", ${te_c.Name} * thismodule"
    .if ( "C" == te_target.language )
      .assign thismodule = ""
    .end if
    .assign left_is_formalizer = FALSE
    .if ( rel_phrase == part.Txt_Phrs )
      .// Left is formalizer, right is participant
      .assign left_is_formalizer = TRUE
    .end if
    .select any assoc from instances of O_OBJ where ( false )
    .assign link_call = "${relate_method.result}( (${te_class.GeneratedName} *) l, (${te_class.GeneratedName} *) r )"
    .invoke persist_relate = PersistCallPostLink( "0", te_relstore, o_obj, o_obj, "left", o_obj, "right", assoc, "" )
    .invoke persist_unrelate = PersistCallPostLink( "1", te_relstore, o_obj, o_obj, "left", o_obj, "right", assoc, "" )
    .invoke PersistAddLinkCalls( o_obj, o_obj, assoc, te_relstore, link_call )
    .select any oref related by rgo->O_REF[R111]
    .assign set_referentials = ""
    .assign reset_referentials = ""
    .if ( not_empty oref )
      .invoke set_refs = SetReferentialAttributes( "right", "left", rto, rgo )
      .if ( rel_phrase == form.Txt_Phrs )
        .invoke set_refs = SetReferentialAttributes( "left", "right", rto, rgo )
      .end if
      .invoke reset_refs = ResetReferentialAttributes( "right", rgo )
      .if ( rel_phrase == part.Txt_Phrs )
        .invoke reset_refs = ResetReferentialAttributes( "left", rgo )
      .end if
      .assign set_referentials = set_refs.body
      .assign reset_referentials = reset_refs.body
    .end if  .// not_empty oid
    .invoke persist_relate = PersistCallPostLink( "0", te_relstore, o_obj, o_obj, "left", o_obj, "right", assoc, "" )
    .invoke persist_unrelate = PersistCallPostLink( "1", te_relstore, o_obj, o_obj, "left", o_obj, "right", assoc, "" )
    .include "${te_file.arc_path}/t.class.relate_reflex.c"
  .end if  .// gen_declaration
.end function
.//
.//============================================================================
.// This function creates the relationship link and unlink methods for a
.// subtype/supertype relationship.
.//
.// Note that we _always_ fully link a subtype to supertype regardless of
.// whether or not the link is navigated in the analysis model.  It is
.// plausable that the relationship may never be navigated, especially in the
.// case of a polymorphic event hierarchy. In which case we need full linkage
.// to forward the event.  Thus, attempting to save a few bytes in the case
.// of an incomplete non-poly model just is not worth the effort.
.//============================================================================
.function CreateSubtypeFormalizerMethods
  .param inst_ref te_relstore
  .param inst_ref o_obj
  .param inst_ref r_rel
  .param boolean  gen_declaration
  .//
  .select any te_file from instances of TE_FILE
  .select any te_target from instances of TE_TARGET
  .select one te_rel related by r_rel->TE_REL[R2034]
  .select one supertype related by r_rel->R_SUBSUP[R206]->R_SUPER[R212]
  .select one supertype_obj related by supertype->R_RTO[R204]->R_OIR[R203]->O_OBJ[R201]
  .//
  .select one rto related by supertype->R_RTO[R204]
  .select any rgo related by r_rel->R_SUBSUP[R206]->R_SUB[R213]->R_RGO[R205] where (selected.Obj_ID == o_obj.Obj_ID)
  .//
  .select one super_te_class related by supertype_obj->TE_CLASS[R2019]
  .select one sub_te_class related by o_obj->TE_CLASS[R2019]
  .select one te_c related by sub_te_class->TE_C[R2064]
  .//
  .invoke relate_method   = GetRelateToName( o_obj, r_rel, "" )
  .invoke unrelate_method = GetUnrelateFromName( o_obj, r_rel, "" )
  .//
  .select one te_nav related by rto->R_OIR[R203]->TE_NAV[R2035]
  .assign rto_NavigatedTo = te_nav.NavigatedTo
  .select one te_nav related by rgo->R_OIR[R203]->TE_NAV[R2035]
  .assign rgo_NavigatedTo = te_nav.NavigatedTo
  .if ( gen_declaration )
    .assign externstatic = "static "
    .assign thismodule = ", ${te_c.Name} *"
    .if ( "C" == te_target.language )
      .assign externstatic = ""
      .assign thismodule = ""
    .end if
    .include "${te_file.arc_path}/t.class.relate_subtype.h"
  .else
    .assign thismodule = ", ${te_c.Name} * thismodule"
    .if ( "C" == te_target.language )
      .assign thismodule = ""
    .end if
    .invoke subtype_data_member = GetRelationshipDataMemberName( supertype_obj, r_rel, "" )
    .invoke supertype_data_member = GetRelationshipDataMemberName( o_obj, r_rel, "" )
    .select one subtype_te_class related by o_obj->TE_CLASS[R2019]
    .assign link_call = "${relate_method.result}( (${super_te_class.GeneratedName} *) l, (${sub_te_class.GeneratedName} *) r )"
    .select any assoc from instances of O_OBJ where ( false )
    .invoke PersistAddLinkCalls( supertype_obj, o_obj, assoc, te_relstore, link_call )
    .select any oref related by rgo->O_REF[R111]
    .assign set_referentials = ""
    .assign reset_referentials = ""
    .if ( not_empty oref )
      .invoke set_refs = SetReferentialAttributes( "supertype", "subtype", rto, rgo )
      .invoke reset_refs = ResetReferentialAttributes( "subtype", rgo )
      .assign set_referentials = set_refs.body
      .assign reset_referentials = reset_refs.body
    .end if  .// not_empty oid
    .invoke persist_relate = PersistCallPostLink( "0", te_relstore, o_obj, supertype_obj, "supertype", o_obj, "subtype", assoc, "" )
    .invoke persist_unrelate = PersistCallPostLink( "1", te_relstore, o_obj, supertype_obj, "supertype", o_obj, "subtype", assoc, "" )
    .include "${te_file.arc_path}/t.class.relate_subtype.c"
  .end if  .// gen_declaration
.end function
.//
.//============================================================================
.// This function creates the relationship link and unlink methods for an
.// associative relationship. 
.//============================================================================
.function CreateAssociativeFormalizerMethods
  .param inst_ref te_relstore
  .param inst_ref r_rel
  .param string   rel_phrase
  .param boolean  gen_declaration
  .//
  .select any te_file from instances of TE_FILE
  .select any te_set from instances of TE_SET
  .select any te_target from instances of TE_TARGET
  .select one te_rel related by r_rel->TE_REL[R2034]
  .select one aone related by r_rel->R_ASSOC[R206]->R_AONE[R209]
  .select one aoth related by r_rel->R_ASSOC[R206]->R_AOTH[R210]
  .select one assr related by r_rel->R_ASSOC[R206]->R_ASSR[R211]
  .//
  .select one aone_rto related by aone->R_RTO[R204]
  .select one aoth_rto related by aoth->R_RTO[R204]
  .select one assr_rgo related by assr->R_RGO[R205]
  .//
  .select one aone_obj related by aone_rto->R_OIR[R203]->O_OBJ[R201]
  .select one aoth_obj related by aoth_rto->R_OIR[R203]->O_OBJ[R201]
  .select one assr_obj related by assr_rgo->R_OIR[R203]->O_OBJ[R201]
  .//
  .select one aone_te_class related by aone_obj->TE_CLASS[R2019]
  .select one aoth_te_class related by aoth_obj->TE_CLASS[R2019]
  .select one assr_te_class related by assr_obj->TE_CLASS[R2019]
  .select one te_c related by assr_te_class->TE_C[R2064]
  .invoke link_method = GetAssociativeLinkMethodName( aone_obj, aoth_obj, assr_obj, r_rel, rel_phrase )
  .invoke unlink_method = GetAssociativeUnlinkMethodName( aone_obj, aoth_obj, assr_obj, r_rel, rel_phrase )
  .//
  .if ( gen_declaration )
    .assign externstatic = "static "
    .assign thismodule = ", ${te_c.Name} *"
    .if ( "C" == te_target.language )
      .assign externstatic = ""
      .assign thismodule = ""
    .end if
    .include "${te_file.arc_path}/t.class.relate_assoc.h"
  .else
    .assign thismodule = ", ${te_c.Name} * thismodule"
    .if ( "C" == te_target.language )
      .assign thismodule = ""
    .end if
    .//
    .invoke aone_data = GetRelationshipDataMemberName( aone_obj, r_rel, rel_phrase )
    .invoke aoth_data = GetRelationshipDataMemberName( aoth_obj, r_rel, rel_phrase )
    .invoke assr_data = GetRelationshipDataMemberName( assr_obj, r_rel, rel_phrase )
    .assign link_call = "${link_method.result}( (${aone_te_class.GeneratedName} *) l, (${aoth_te_class.GeneratedName} *) r, (${assr_te_class.GeneratedName} *) a )"
    .invoke PersistAddLinkCalls( aone_obj, aoth_obj, assr_obj, te_relstore, link_call )
    .select any oref related by assr_rgo->O_REF[R111]
    .assign set_aone_referentials = ""
    .assign set_aoth_referentials = ""
    .assign reset_referentials = ""
    .if ( not_empty oref )
      .invoke set_aone_refs = SetReferentialAttributes( "aone", "assr", aone_rto, assr_rgo )
      .invoke set_aoth_refs = SetReferentialAttributes( "aoth", "assr", aoth_rto, assr_rgo )
      .invoke reset_refs = ResetReferentialAttributes( "assr", assr_rgo )
      .assign set_aone_referentials = set_aone_refs.body
      .assign set_aoth_referentials = set_aoth_refs.body
      .assign reset_referentials = reset_refs.body
    .end if  .// not_empty oid
    .invoke persist_relate = PersistCallPostLink( "0", te_relstore, assr_obj, aone_obj, "aone", aoth_obj, "aoth", assr_obj, "assr" )
    .invoke persist_unrelate = PersistCallPostLink( "1", te_relstore, assr_obj, aone_obj, "aone", aoth_obj, "aoth", assr_obj, "assr" )
    .include "${te_file.arc_path}/t.class.relate_assoc.c"
  .end if  .// gen_declaration
.end function
.//
.//============================================================================
.// This function creates the relationship link and unlink methods for an
.// associative reflexive relationship. 
.//============================================================================
.function CreateAssociativeReflexiveFormalizerMethods
  .param inst_ref te_relstore
  .param inst_ref r_rel
  .param string   rel_phrase
  .param boolean  gen_declaration
  .param boolean  towards_aone
  .//
  .select any te_file from instances of TE_FILE
  .select any te_set from instances of TE_SET
  .select any te_target from instances of TE_TARGET
  .select one aone related by r_rel->R_ASSOC[R206]->R_AONE[R209]
  .select one aoth related by r_rel->R_ASSOC[R206]->R_AOTH[R210]
  .select one assr related by r_rel->R_ASSOC[R206]->R_ASSR[R211]
  .//
  .select one aone_rto related by aone->R_RTO[R204]
  .select one aoth_rto related by aoth->R_RTO[R204]
  .select one assr_rgo related by assr->R_RGO[R205]
  .//
  .select one assoc_obj related by aone_rto->R_OIR[R203]->O_OBJ[R201]
  .select one assr_obj related by assr_rgo->R_OIR[R203]->O_OBJ[R201]
  .select one assoc_te_class related by assoc_obj->TE_CLASS[R2019]
  .select one assr_te_class related by assr_obj->TE_CLASS[R2019]
  .select one te_c related by assr_te_class->TE_C[R2064]
  .select one te_rel related by r_rel->TE_REL[R2034]
  .//
  .invoke link_method = GetAssociativeLinkMethodName( assoc_obj, assoc_obj, assr_obj, r_rel, rel_phrase )
  .invoke unlink_method = GetAssociativeUnlinkMethodName( assoc_obj, assoc_obj, assr_obj, r_rel, rel_phrase )
  .//
  .if ( gen_declaration )
    .assign externstatic = "static "
    .assign thismodule = ", ${te_c.Name} *"
    .if ( "C" == te_target.language )
      .assign externstatic = ""
      .assign thismodule = ""
    .end if
    .include "${te_file.arc_path}/t.class.relate_assref.h"
  .else
    .assign thismodule = ", ${te_c.Name} * thismodule"
    .if ( "C" == te_target.language )
      .assign thismodule = ""
    .end if
    .// CDS Here we need to distinguish between aone and aother for role symmetric
    .// reflexive relationships (where the relationship phrase is identical on both
    .// ends of the relationship).
    .invoke aone_data = GetRelationshipDataMemberName( assoc_obj, r_rel, aone.Txt_Phrs )
    .invoke aoth_data = GetRelationshipDataMemberName( assoc_obj, r_rel, aoth.Txt_Phrs )
    .invoke aone_assr_data = GetRelationshipDataMemberName( assr_obj, r_rel, aone.Txt_Phrs  )
    .invoke aoth_assr_data = GetRelationshipDataMemberName( assr_obj, r_rel, aoth.Txt_Phrs  )
    .assign link_call = "${link_method.result}( (${assoc_te_class.GeneratedName} *) l, (${assoc_te_class.GeneratedName} *) r, (${assr_te_class.GeneratedName} *) a )"
    .invoke PersistAddLinkCalls( assoc_obj, assoc_obj, assr_obj, te_relstore, link_call )
    .invoke persist_relate = PersistCallPostLink( "0", te_relstore, assr_obj, assoc_obj, "left", assoc_obj, "right", assr_obj, "assr" )
    .invoke persist_unrelate = PersistCallPostLink( "1", te_relstore, assr_obj, assoc_obj, "left", assoc_obj, "right", assr_obj, "assr" )
    .select any oref related by assr_rgo->O_REF[R111]
    .assign set_aone_referentials = ""
    .assign set_aoth_referentials = ""
    .assign reset_referentials = ""
    .if ( not_empty oref )
      .if ( towards_aone )
        .invoke set_aone_refs = SetReferentialAttributes( "right", "assr", aone_rto, assr_rgo )
        .invoke set_aoth_refs = SetReferentialAttributes( "left", "assr", aoth_rto, assr_rgo )
        .assign set_aone_referentials = set_aone_refs.body
        .assign set_aoth_referentials = set_aoth_refs.body
      .else
        .invoke set_aone_refs = SetReferentialAttributes( "left", "assr", aone_rto, assr_rgo )
        .invoke set_aoth_refs = SetReferentialAttributes( "right", "assr", aoth_rto, assr_rgo )
        .assign set_aone_referentials = set_aone_refs.body
        .assign set_aoth_referentials = set_aoth_refs.body
      .end if
      .invoke reset_refs = ResetReferentialAttributes( "assr", assr_rgo )
      .assign reset_referentials = reset_refs.body
    .end if
    .include "${te_file.arc_path}/t.class.relate_assref.c"
  .end if
  .//
.end function
.//
.//============================================================================
.// Copy across the (accessed) identifier into the referential attribute(s).
.// NOTE:  Predicates - The following logic assumes that:
.// 1) The relationship is formalized (<oid> will exist)
.//============================================================================
.function SetReferentialAttributes
  .param string part_ptr
  .param string form_ptr
  .param inst_ref r_rto
  .param inst_ref r_rgo
  .//
  .select any te_file from instances of TE_FILE
  .select any te_instance from instances of TE_INSTANCE
  .select any te_string from instances of TE_STRING
  .select one oid related by r_rto->O_ID[R109]
  .assign key_number = oid.Oid_ID + 1
  .// Get set of Object Identifying Attribute(s)
  .select many oida_set related by oid->O_OIDA[R105]
  .for each oida in oida_set
    .// Get the identifying attribute corresponding to this <oida> instance.
    .select any ident_attr related by oida->O_ATTR[R105] where (selected.Attr_ID == oida.Attr_ID)
    .// Get the Referred To Identifier Attribute (O_RTIDA) instance reference.
    .select any rtida related by r_rto->O_RTIDA[R110] where ((selected.Attr_ID == oida.Attr_ID) and ((selected.Obj_ID == oida.Obj_ID) and (selected.Oid_ID == oida.Oid_ID)))
    .// There can be more than one valid O_REF here, so get _any_ one.
    .// Note:  If MANY <rtida>, we need to rip through the (possible) combined referentials,
    .// unlinking any non-constrained elements.
    .select any ref related by rtida->O_REF[R111] where ( (selected.Obj_ID == r_rgo.Obj_ID) and (selected.OIR_ID == r_rgo.OIR_ID) )
    .// Get the referential attribute corresponding to the current <ident_attr>.
    .select one ref_attr related by ref->O_RATTR[R108]->O_ATTR[R106]
    .select one ref_te_attr related by ref_attr->TE_ATTR[R2033]
    .if ( ref_te_attr.translate )
      .select one ident_te_attr related by ident_attr->TE_ATTR[R2033]
      .invoke r = GetAttributeCodeGenType( ref_attr )
      .assign te_dt = r.result
      .assign initial_value = te_dt.Initial_Value
      .include "${te_file.arc_path}/t.class.set_refs.c"
    .end if
  .end for  .// ident_attr in oida_set
.end function
.//
.//============================================================================
.// Provide code to reset the referentials after an UNRELATE statement.
.//============================================================================
.function ResetReferentialAttributes
  .param string   form_ptr
  .param inst_ref r_rgo
  .//
  .select any te_file from instances of TE_FILE
  .select any te_instance from instances of TE_INSTANCE
  .select any te_string from instances of TE_STRING
  .select many ref_attr_set related by r_rgo->O_REF[R111]->O_RATTR[R108]->O_ATTR[R106]
  .for each ref_attr in ref_attr_set
    .select one ref_te_attr related by ref_attr->TE_ATTR[R2033]
    .if ( ref_te_attr.translate )
      .invoke r = GetAttributeCodeGenType( ref_attr )
      .assign te_dt = r.result
      .include "${te_file.arc_path}/t.class.reset_refs.c"
    .end if
  .end for  .// ref_attr in ref_attr_set
.end function
.//
.//============================================================================
.// Update the relationship storage instance with additional information
.// regarding the declaration and init/cleanup of relationship data/code.
.//============================================================================
.function AddRelationshipStorage
  .param frag_ref rel_info
  .param inst_ref te_relstore
  .//
  .assign this_obj = rel_info.obj
  .assign related_obj = rel_info.related_obj
  .select one related_te_class related by related_obj->TE_CLASS[R2019]
  .select one te_c related by related_te_class->TE_C[R2064]
  .select any te_instance from instances of TE_INSTANCE
  .select any te_set from instances of TE_SET
  .select any te_typemap from instances of TE_TYPEMAP
  .//
  .assign rto = rel_info.rto
  .assign rgo = rel_info.rgo
  .assign rel = rel_info.rel
  .//
  .// Get the base names of the data member(s) to be generated.
  .invoke member_data_name = GetRelationshipDataMemberName( related_obj, rel, rel_info.rel_phrase )
  .//
  .assign storage_needed = FALSE
  .assign phrase = ""
  .if ( "" != rel_info.rel_phrase )
    .// Include relationship phrase in reflexive relationship commenting.
    .assign phrase = ".'${rel_info.rel_phrase}'"
  .end if
  .//
  .if ( this_obj.Obj_ID != related_obj.Obj_ID )
    .// Non-reflexive - linkage based on navigation needs
    .if ( rel_info.is_formalizer )
      .select one te_nav related by rto->R_OIR[R203]->TE_NAV[R2035]
      .if ( te_nav.NavigatedTo or te_c.OptDisabled )
        .assign storage_needed = TRUE
      .else
        .select one super related by rto->R_SUPER[R204]
        .if ( not_empty super )
          .assign storage_needed = TRUE
        .end if
      .end if
    .else
      .select one te_nav related by rgo->R_OIR[R203]->TE_NAV[R2035]
      .if ( te_nav.NavigatedTo or te_c.OptDisabled )
        .assign storage_needed = TRUE
      .else
        .select one sub related by rgo->R_SUB[R205]
        .if ( not_empty sub )
          .assign storage_needed = TRUE
        .end if
      .end if
    .end if
  .else
    .// Reflexive - always need bi-directional linkage
    .assign storage_needed = TRUE
  .end if
  .//
  .if ( rel_info.gen_declaration )
    .// Add relationship data storage declaration.
    .// Links to related objects are stored as member data of the class.
    .assign data_declare = ""
    .//
    .if ( rel_info.multiplicity == 0 )
      .if ( not rel_info.is_supertype )
        .// relationship data storage for link to ONE
        .if ( storage_needed )
          .assign data_declare = "  ${related_te_class.GeneratedName} * ${member_data_name.result};\n"
        .else
          .assign data_declare = "  /* Note:  No storage needed for ${this_obj.Key_Lett}->${related_obj.Key_Lett}[R${rel.Numb}${phrase}] */\n"
        .end if
      .else
        .if ( rel_info.generate_subtype )
          .// optimized relationship storage for link to a subtype
          .assign data_declare = "  void * ${member_data_name.result};\n  ${te_typemap.object_number_name} ${member_data_name.obj_id};\n"
          .assign rel_info.generate_subtype = FALSE
        .end if
      .end if  .// not rel_info.is_supertype
    .else
      .// relationship data storage for link to MANY
      .if ( storage_needed )
        .assign data_declare = "  ${te_set.scope}${te_set.base_class} ${member_data_name.result};\n"
      .else
        .assign data_declare = "  /* Note:  No storage needed for ${this_obj.Key_Lett}->${related_obj.Key_Lett}[R${rel.Numb}${phrase}] */\n"
      .end if
    .end if
    .//
    .assign te_relstore.data_declare = te_relstore.data_declare + data_declare
  .else
    .// Add relationship data storage definition.
    .assign data_init = ""
    .assign data_fini = ""
    .//
    .if ( rel_info.multiplicity == 0 )
      .// relationship data storage for link to ONE
      .if ( not rel_info.is_supertype )
        .if ( storage_needed )
          .assign data_init = "  ${te_instance.self}->${member_data_name.result} = 0;\n"
          .assign data_fini = "  ${te_instance.self}->${member_data_name.result} = 0;\n"
        .end if
      .else
        .if ( rel_info.generate_subtype )
          .// optimized relationship storage for link to a subtype
          .assign data_init = "  ${te_instance.self}->${member_data_name.result} = 0;\n  ${te_instance.self}->${member_data_name.obj_id} = 0;\n"
          .if ( storage_needed )
            .assign data_fini = "  ${te_instance.self}->${member_data_name.result} = 0;\n  ${te_instance.self}->${member_data_name.obj_id} = 0;\n"
            .assign rel_info.generate_subtype = FALSE
          .end if
        .end if  .// rel_info.generate_subtype
      .end if  .// not rel_info.is_supertype
    .else
      .// relationship data storage for link to MANY
      .if ( storage_needed )
        .assign data_init = "  ${te_set.init}( &${te_instance.self}->${member_data_name.result} );\n"
        .assign data_fini = "  ${te_set.module}${te_set.clear}( &${te_instance.self}->${member_data_name.result} );\n"
      .end if
    .end if
    .//
    .// Propagate local expressions upon te_relstore instance output attributes.
    .assign te_relstore.data_init = te_relstore.data_init + data_init
    .assign te_relstore.data_fini = te_relstore.data_fini + data_fini
    .select one te_rel related by rel->TE_REL[R2034]
    .assign te_rel.storage_needed = storage_needed
    .//
  .end if  .// rel_info.gen_declaration
.end function
.//
.//============================================================================
.// Output Fragment Attributes:
.// <body> :  Generated code for the relationship methods.
.//
.// Modifies:
.// <te_relstore> :  Requisite storage components for the association are appended.
.//============================================================================
.function ImplementRelationshipFundamentals
  .param frag_ref rel_info
  .param inst_ref te_relstore
  .select any te_file from instances of TE_FILE
  .assign rto = rel_info.rto
  .assign rgo = rel_info.rgo
  .assign rel = rel_info.rel
  .// Append relationship data storage components to te_relstore instance.
  .invoke AddRelationshipStorage( rel_info, te_relstore )
  .if ( rel_info.gen_declaration )
    .assign gen_navigate = FALSE
    .if ( rel_info.is_supertype or ( rel_info.multiplicity != 0 ) )
      .assign gen_navigate = TRUE
    .end if
    .if ( gen_navigate )
      .// Get the names of the object classes involved.
      .assign this_object       = rel_info.obj
      .assign related_object    = rel_info.related_obj
      .//
      .// Get the base names of the methods and data members to be generated.
      .invoke navigate_method  = GetNavigateLinkMethodName( this_object, related_object, rel, rel_info.rel_phrase )
      .invoke member_data_name = GetRelationshipDataMemberName( related_object, rel, rel_info.rel_phrase )
      .//
      .// Add the relationship navigation accessor method declaration as an inline
      .select one te_class related by this_object->TE_CLASS[R2019]
      .select one related_te_class related by related_object->TE_CLASS[R2019]
      .select one te_c related by te_class->TE_C[R2064]
      .select one te_nav1 related by rto->R_OIR[R203]->TE_NAV[R2035]
      .select one te_nav2 related by rgo->R_OIR[R203]->TE_NAV[R2035]
      .assign navigated = ( te_nav1.NavigatedTo or te_nav2.NavigatedTo )
      .include "${te_file.arc_path}/t.class.link.h"
    .end if  .// gen_navigate
  .end if  .// rel_info.gen_declaration
.end function
.//
.//============================================================================
.// This function creates a fragment to be used to convey informational
.// parameters to functions which generate implementation code for
.// class association methods and member data.
.//
.// Input Parameters:
.// <obj> :  Instance reference (O_OBJ) to the object for which relationship
.//   methods are being generated (e.g., _near end_ object).
.// <related_obj> :  Instance reference (O_OBJ) to the object that is the
.//   _distant end_ in the relationship with <obj>
.// <rel> :  Instance reference (R_REL) to the relationship between <obj>
.//   and <related_obj>.
.// <rto> :  Instance reference (R_RTO) to the _Referred To Object In
.//   Relationship_ (e.g., the participant object in <rel>).
.// <rgo> :  Instance reference (R_RGO) to the _Referring Object In
.//   Relationship_ (e.g., the formalizing object in <rel>).
.//============================================================================
.function CreateRelInfoFragment
  .param inst_ref o_obj
  .param inst_ref related_o_obj
  .param inst_ref r_rel
  .param inst_ref r_rto
  .param inst_ref r_rgo
  .//
  .invoke attr_rel_info = model_class_rel_info()
  .assign attr_rel_info.obj = o_obj
  .assign attr_rel_info.related_obj = related_o_obj
  .assign attr_rel_info.rel = r_rel
  .assign attr_rel_info.rto = r_rto
  .assign attr_rel_info.rgo = r_rgo
.end function
.//
.//============================================================================
.// Clean up the input instance te_relstore.
.//============================================================================
.function FiniRelStorageFragment
  .param inst_ref te_relstore
  .// delete object instance te_relstore;
  .assign te_relstore.data_declare = ""
  .assign te_relstore.data_init    = ""
  .assign te_relstore.data_fini    = ""
  .assign te_relstore.link_calls   = ""
  .assign te_relstore.link_index   = 0
.end function
.//
.//============================================================================
.// Output Fragment Attributes:
.// <left_mult> String. Multiplicity of the left object in the
.//             relationship link.
.// <right_mult> String. Multiplicity of the right object in the
.//              relationship link.
.// <left_is_formalizer> 
.// <reflexive> 
.// <rgo> 
.// <rto> 
.//
.// Predicates:
.// 1) The relationship <rel> is assumed to be formalized (excluding
.//    composition).
.// 2) This function should only be used for chain link processing.
.//    Note that the link processing for traversing an associative relationship
.//    assures that this function will never see a link from R_AONE to R_OTH;
.//    to will see two steps through the associator, one link at a time.
.//=============================================================================
.function GetLinkParameters
  .param inst_ref left_o_obj
  .param inst_ref right_o_obj
  .param inst_ref r_rel
  .param string rel_phrase
  .//
  .assign attr_left_mult = "one"
  .assign attr_right_mult = "one"
  .//
  .assign attr_left_is_formalizer = FALSE
  .assign attr_reflexive = FALSE
  .//
  .select any attr_rgo from instances of R_RGO
  .select any attr_rto from instances of R_RTO
  .//
  .select one simple_rel related by r_rel->R_SIMP[R206]
  .if ( not_empty simple_rel )
    .select one formalizer related by simple_rel->R_FORM[R208]
    .select one participant related by simple_rel->R_PART[R207]
    .select one attr_rgo related by formalizer->R_RGO[R205]
    .select one attr_rto related by participant->R_RTO[R204]
    .//
    .if ( participant.Obj_ID != formalizer.Obj_ID )
      .// *** Normal Simple Relationship
      .if ( left_o_obj.Obj_ID == formalizer.Obj_ID )
        .// Left object is formalizer, right object is participant.
        .assign attr_left_is_formalizer = TRUE
        .if ( formalizer.Mult != 0 )
          .assign attr_left_mult = "many"
        .end if
        .if ( participant.Mult != 0 )
          .assign attr_right_mult = "many"
        .end if
      .else
        .// right_o_obj.Obj_ID == formalizer.Obj_ID
        .// Left object is participant, right object is formalizer.
        .if ( formalizer.Mult != 0 )
          .assign attr_right_mult = "many"
        .end if
        .if ( participant.Mult != 0 )
          .assign attr_left_mult = "many"
        .end if
      .end if
      .//
    .else
      .// *** Simple Reflexive Relationship
      .assign attr_reflexive = TRUE
      .if ( rel_phrase == participant.Txt_Phrs )
        .// Left object is formalizer, right object is participant.
        .assign attr_left_is_formalizer = TRUE
        .if ( formalizer.Mult != 0 )
          .assign attr_left_mult = "many"
        .end if
        .if ( participant.Mult != 0 )
          .assign attr_right_mult = "many"
        .end if
      .elif ( rel_phrase == formalizer.Txt_Phrs )
        .// Left object is participant, right object is formalizer.
        .if ( formalizer.Mult != 0 )
          .assign attr_right_mult = "many"
        .end if
        .if ( participant.Mult != 0 )
          .assign attr_left_mult = "many"
        .end if
      .else
        .print "\nLOGIC/SQL ERROR:  Bogus reflexive simple relationship phrase:  ${rel_phrase}."
        .print "part ${participant.Txt_Phrs} form ${formalizer.Txt_Phrs} rel ${rel_phrase}"
        .exit 101
      .end if
    .end if
    .//
  .else
    .select one subtype_supertype_rel related by r_rel->R_SUBSUP[R206]
    .// Subtype-Supertype relationship?
    .if ( not_empty subtype_supertype_rel )
      .select one attr_rto related by r_rel->R_SUBSUP[R206]->R_SUPER[R212]->R_RTO[R204]
      .//
      .// Left object is the subtype (formalizer)?
      .select any subtype related by subtype_supertype_rel->R_SUB[R213] where ( selected.Obj_ID == left_o_obj.Obj_ID )
      .if ( not_empty subtype )
        .assign attr_left_is_formalizer = TRUE
        .select one attr_rgo related by subtype->R_RGO[R205]
      .else
        .// Left is supertype, right is subtype
        .select any subtype related by subtype_supertype_rel->R_SUB[R213] where ( selected.Obj_ID == right_o_obj.Obj_ID )
        .select one attr_rgo related by subtype->R_RGO[R205]
      .end if
    .else
      .//
      .select one associative_rel related by r_rel->R_ASSOC[R206]
      .if ( not_empty associative_rel )
        .select one one_side related by associative_rel->R_AONE[R209]
        .select one other_side related by associative_rel->R_AOTH[R210]
        .select one associator related by associative_rel->R_ASSR[R211]
        .//
        .select one attr_rgo related by associator->R_RGO[R205]
        .//
        .if ( left_o_obj.Obj_ID == associator.Obj_ID )
          .// Left object is associator
          .assign attr_left_is_formalizer = TRUE
          .if ( one_side.Obj_ID == other_side.Obj_ID )
            .// Reflexive Associative relationship
            .if ( rel_phrase == one_side.Txt_Phrs )
              .// Right object is R_AONE
              .// Left object is associator R_ASSR
              .// Leave attr_right_mult = to ONE since always true ?
              .//
              .// Associators multiplicity takes on R_AOTH multiplicity
              .if ( other_side.Mult != 0 )
                .assign attr_left_mult = "many"
              .end if
              .select one attr_rto related by one_side->R_RTO[R204]
            .elif ( rel_phrase == other_side.Txt_Phrs )
              .// Right object is R_AOTH
              .// Left object is associator R_ASSR
              .// Leave attr_right_mult = to ONE since always true ?
              .//
              .// Associators multiplicity takes on R_AONE multiplicity
              .if ( one_side.Mult != 0 )
                .assign attr_left_mult = "many"
              .end if
              .select one attr_rto related by other_side->R_RTO[R204]
            .end if
          .else
            .// *** Simple Associative
            .// Left object is associator
            .// Right object multiplicity is always ONE, do not change attr_right_mult
           .if ( right_o_obj.Obj_ID == one_side.Obj_ID )
              .// Right object is R_AONE
              .// Left object (associator) takes on R_AOTH multiplicity
              .if ( other_side.Mult != 0 )
                .assign attr_left_mult = "many"
              .end if
              .select one attr_rto related by one_side->R_RTO[R204]
            .else
              .// Right object is R_AOTH
              .// Left object (associator) takes on R_AONE multiplicity
              .if ( one_side.Mult != 0 )
                .assign attr_left_mult = "many"
              .end if
              .select one attr_rto related by other_side->R_RTO[R204]
            .end if
          .end if
        .elif ( right_o_obj.Obj_ID == associator.Obj_ID )
          .// Right object is associator
          .if ( one_side.Obj_ID == other_side.Obj_ID)
            .// Reflexive Associative
            .// Leave attr_left_mult = to ONE since always true
            .// Associators multiplicity takes on R_AOTH multiplicity
            .if ( one_side.Txt_Phrs != rel_phrase )
              .// Left object is R_AONE
              .// Associators multiplicity takes on R_AOTH multiplicity
              .if ( other_side.Mult != 0 )
                .assign attr_right_mult = "many"
              .end if
              .select one attr_rto related by one_side->R_RTO[R204]
            .elif ( other_side.Txt_Phrs != rel_phrase )
              .// Left object is R_AOTH
              .// Associators multiplicity takes on R_AONE multiplicity
              .//
              .if ( one_side.Mult != 0 )
                .assign attr_right_mult = "many"
              .end if
              .select one attr_rto related by other_side->R_RTO[R204]
            .else
              .print "\nLOGIC ERROR:  Bogus Associative Reflexive Relationship phrase!"
              .exit 101
            .end if   .// one_side.Obj_ID == other_side.Obj_ID
          .else
            .// Simple Associative
            .// Left multiplicity is always ONE, do not change attr_left_mult
            .if ( left_o_obj.Obj_ID == one_side.Obj_ID )
              .// Left object is R_AONE
              .// Right object takes on R_AOTH multiplicity
              .if ( other_side.Mult != 0 )
                .assign attr_right_mult = "many"
              .end if
              .select one attr_rto related by one_side->R_RTO[R204]
            .else 
              .// Left object is R_AOTH
              .// Right object takes on R_AONE multiplicity
              .if ( one_side.Mult != 0 )
                .assign attr_right_mult = "many"
              .end if
              .select one attr_rto related by other_side->R_RTO[R204]
            .end if
          .end if
        .else
          .assign msg = "\nTRANSLATOR LOGIC ERROR!"
          .assign msg = msg + "\n${left_o_obj.Key_Lett}->${right_o_obj.Key_Lett}[R${r_rel.Numb}]"
          .assign msg = msg + "\nNeither object is associator in chain link processing!"
          .print "${msg}"
          .exit 101
        .end if
      .else
        .select one composed_rel related by r_rel->R_COMP[R206]
        .if ( not_empty composed_rel )
          .assign msg = "\nTRANSLATOR SUPPORT ERROR!"
          .assign msg = msg + "\n${left_o_obj.Key_Lett}->${right_o_obj.Key_Lett}[R${r_rel.Numb}]"
          .assign msg = msg + "\nComposition navigation not supported!"
          .print "${msg}"
          .exit 101
        .else 
          .// In case BridgePoint adds a new subtype of R_REL meta-model object.
          .assign msg = "\nTRANSLATOR LOGIC ERROR!"
          .assign msg = msg + "\n${left_o_obj.Key_Lett}->${right_o_obj.Key_Lett}[R${r_rel.Numb}]"
          .assign msg = msg + "\nUnknown relationship type!"
          .print "${msg}"
          .exit 101
        .end if   .// not_empty composed_rel
      .end if   .// not_empty associative_rel
    .end if   .// not_empty subtype_supertype_rel
  .end if   .// not_empty simple_rel
.end function
.//
.//============================================================================
.//   Sort the instances in the instance set <item_set> in ascending numeric
.// order, based on the value of the Numb (integer) attribute value of
.// each instance. The Order (integer) attribute value of each instance will
.// be set to contain a value relative to Numb, indicating the position
.// the instance has in the ordered set.
.//   This function is definately *slow*, but will work with any objects
.// which contain integer attributes <Numb> and <Order>.
.//============================================================================
.function SortSetAscendingByAttr_Numb
  .param inst_ref_set item_set
  .//
  .assign attr_last = 0
  .// Clear the Order attribute of all set members.
  .for each item in item_set
    .assign item.Order = 0
  .end for
  .// simple pseudo bubble sort
  .assign item_set_copy = item_set
  .for each item in item_set
    .for each item_copy in item_set_copy
      .if ( item.Numb != item_copy.Numb )
        .if ( item_copy.Numb > item.Numb )
          .assign item_copy.Order = item_copy.Order + 1
        .end if
      .end if
    .end for
    .assign attr_last = item_copy.Order
  .end for
.end function
.//
.//============================================================================
.// Given a set of instances, sets the attribute Order to
.// a value corresponding to the alphabetical order its Name attribute
.// is in the set
.//
.// <item_set> - from instances of anything with Name and Order attributes
.//============================================================================
.function SortSetAlphabeticallyByNameAttr
  .param inst_ref_set item_set
  .//
  .// Clear the Order attribute of all set members.
  .for each item in item_set
    .assign item.Order = 0
  .end for
  .//
  .assign item_set_copy = item_set
  .for each item in item_set
    .for each item_copy in item_set_copy
      .if ( item.Name != item_copy.Name )
        .if ( item_copy.Name > item.Name )
          .assign item_copy.Order = item_copy.Order + 1
        .end if
      .end if
    .end for
  .end for
.end function
.//
.//============================================================================
.// Return <result> the multiplicity/conditionality string.
.//
.// Inputs:
.// <multiplicity>   : 0 = one, 1 = many
.// <conditionality> : 0 = unconditional, 1 = conditional
.//============================================================================
.function GetMultCondString
  .param integer multiplicity
  .param integer conditionality
  .//
  .assign attr_result = "??"
  .if ( multiplicity == 0 )
    .if ( conditionality == 0 )
      .assign attr_result = "1"
    .elif ( conditionality == 1 )
      .assign attr_result = "0..1"
    .end if 
  .elif ( multiplicity == 1 )
    .if ( conditionality == 0 )
      .assign attr_result = "0..*"
    .elif ( conditionality == 1 )
      .assign attr_result = "*"
    .end if 
  .end if
.end function
.//
.//============================================================================
.// This function will be eliminated (modeled) as part of the elimination
.// of the use of frag_ref.
.function model_class_rel_info
  .assign attr_multiplicity = 0
  .select any r_rto from instances of R_RTO where ( false )
  .assign attr_rto = r_rto
  .select any r_rel from instances of R_REL where ( false )
  .assign attr_rel = r_rel
  .select any r_rgo from instances of R_RGO where ( false )
  .assign attr_rgo = r_rgo
  .select any o_obj from instances of O_OBJ where ( false )
  .assign attr_related_obj = o_obj
  .select any o_obj from instances of O_OBJ where ( false )
  .assign attr_obj = o_obj
  .select any r_oir from instances of R_OIR where ( false )
  .assign attr_oir = r_oir
  .assign attr_gen_link_methods = false
  .assign attr_rel_phrase = ""
  .assign attr_is_formalizer = false
  .assign attr_is_supertype = false
  .assign attr_generate_subtype = false
  .assign attr_gen_declaration = false
.end function
.//
