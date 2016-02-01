/*----------------------------------------------------------------------------
 * File:  masl_population_class.c
 *
 * Class:       population  (population)
 * Component:   masl
 *
 * your copyright statement can go here (from te_copyright.body)
 *--------------------------------------------------------------------------*/

#include "masl_sys_types.h"
#include "LOG_bridge.h"
#include "STRING_bridge.h"
#include "T_bridge.h"
#include "TRACE_bridge.h"
#include "masl_classes.h"

/*
 * class operation:  populate
 */
void
masl_population_op_populate( c_t p_element[ESCHER_SYS_MAX_STRING_LEN], c_t p_value[8][ESCHER_SYS_MAX_STRING_LEN] )
{
  c_t element_name[ESCHER_SYS_MAX_STRING_LEN];c_t * value[8]={0,0,0,0,0,0,0,0};c_t element[ESCHER_SYS_MAX_STRING_LEN];masl_population * population=0;
  /* ASSIGN element = PARAM.element */
  Escher_strcpy( element, p_element );
  /* ASSIGN value = PARAM.value */
  value[0] = p_value[0];
  value[1] = p_value[1];
  value[2] = p_value[2];
  value[3] = p_value[3];
  value[4] = p_value[4];
  value[5] = p_value[5];
  value[6] = p_value[6];
  value[7] = p_value[7];
  /* SELECT any population FROM INSTANCES OF population */
  population = (masl_population *) Escher_SetGetAny( &pG_masl_population_extent.active );
  /* IF ( empty population ) */
  if ( ( 0 == population ) ) {
    /* CREATE OBJECT INSTANCE population OF population */
    population = (masl_population *) Escher_CreateInstance( masl_DOMAIN_ID, masl_population_CLASS_NUMBER );
  }
  /* ASSIGN element_name =  */
  Escher_strcpy( element_name, "" );
  /* IF ( ( ( ( regularrel == element ) or ( associative == element ) ) or ( subsuper == element ) ) ) */
  if ( ( ( ( Escher_strcmp( "regularrel", element ) == 0 ) || ( Escher_strcmp( "associative", element ) == 0 ) ) || ( Escher_strcmp( "subsuper", element ) == 0 ) ) ) {
    /* ASSIGN element_name = relationship */
    Escher_strcpy( element_name, "relationship" );
  }
  else if ( ( ( Escher_strcmp( "service", element ) == 0 ) || ( Escher_strcmp( "function", element ) == 0 ) ) ) {
    /* ASSIGN element_name = activity */
    Escher_strcpy( element_name, "activity" );
  }
  else {
    /* ASSIGN element_name = element */
    Escher_strcpy( element_name, element );
  }
  /* IF ( (  == value[0] ) ) */
  if ( ( Escher_strcmp( "", value[0] ) == 0 ) ) {
    masl_element * current_element=0;
    /* SELECT one current_element RELATED BY population->element[R3784.has current] WHERE ( ( SELECTED.name == element_name ) ) */
    {current_element = 0;
    {masl_element * selected = ( 0 != population ) ? population->element_R3784_has_current : 0;
    if ( ( 0 != selected ) && ( Escher_strcmp( selected->name, element_name ) == 0 ) ) {
      current_element = selected;
    }}}
    /* IF ( not_empty current_element ) */
    if ( ( 0 != current_element ) ) {
      masl_element * parent_element=0;
      /* TRACE::log( flavor:levi, id:99, message:( popping stack:  + element ) ) */
      TRACE_log( "levi", 99, Escher_stradd( "popping stack: ", element ) );
      /* SELECT one parent_element RELATED BY current_element->element[R3787.child of] */
      parent_element = ( 0 != current_element ) ? current_element->element_R3787_child_of : 0;
      /* UNRELATE population FROM current_element ACROSS R3784 */
      masl_element_R3784_Unlink_has_current( population, current_element );
      /* RELATE population TO parent_element ACROSS R3784 */
      masl_element_R3784_Link_has_current( population, parent_element );
      /* UNRELATE population FROM current_element ACROSS R3789 */
      masl_element_R3789_Unlink_has_active( population, current_element );
    }
    /* RETURN  */
    return;  }
  /* IF ( ( project == element ) ) */
  if ( ( Escher_strcmp( "project", element ) == 0 ) ) {
    masl_project * project;masl_element * new_element=0;
    /* ASSIGN project = project::populate(name:value[0]) */
    project = masl_project_op_populate(value[0]);
    /* SELECT one new_element RELATED BY project->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != project ) {
    masl_markable * markable_R3783 = project->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "domain", element ) == 0 ) ) {
    masl_domain * domain;masl_element * new_element=0;masl_project * parent_project=0;
    /* SELECT one parent_project RELATED BY population->element[R3784.has current]->markable[R3786]->project[R3783] */
    parent_project = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_project_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_project = (masl_project *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN domain = domain::populate(name:value[0], project:parent_project) */
    domain = masl_domain_op_populate(value[0], parent_project);
    /* SELECT one new_element RELATED BY domain->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != domain ) {
    masl_markable * markable_R3783 = domain->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "object", element ) == 0 ) ) {
    masl_object * object;masl_element * new_element=0;masl_domain * parent_domain=0;
    /* SELECT one parent_domain RELATED BY population->element[R3784.has current]->markable[R3786]->domain[R3783] */
    parent_domain = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_domain_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_domain = (masl_domain *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN object = object::populate(domain:parent_domain, name:value[0]) */
    object = masl_object_op_populate(parent_domain, value[0]);
    /* SELECT one new_element RELATED BY object->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != object ) {
    masl_markable * markable_R3783 = object->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "terminator", element ) == 0 ) ) {
    masl_terminator * terminator;masl_element * new_element=0;masl_domain * parent_domain=0;
    /* SELECT one parent_domain RELATED BY population->element[R3784.has current]->markable[R3786]->domain[R3783] */
    parent_domain = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_domain_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_domain = (masl_domain *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN terminator = terminator::populate(domain:parent_domain, name:value[0]) */
    terminator = masl_terminator_op_populate(parent_domain, value[0]);
    /* SELECT one new_element RELATED BY terminator->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != terminator ) {
    masl_markable * markable_R3783 = terminator->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( ( Escher_strcmp( "service", element ) == 0 ) || ( Escher_strcmp( "function", element ) == 0 ) ) ) {
    masl_activity * activity=0;masl_element * new_element=0;masl_object * parent_object=0;masl_terminator * parent_terminator=0;masl_domain * parent_domain=0;
    /* SELECT one parent_domain RELATED BY population->element[R3784.has current]->markable[R3786]->domain[R3783] */
    parent_domain = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_domain_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_domain = (masl_domain *) R3786_subtype->R3783_subtype;
}}}}
    /* SELECT one parent_terminator RELATED BY population->element[R3784.has current]->markable[R3786]->terminator[R3783] */
    parent_terminator = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_terminator_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_terminator = (masl_terminator *) R3786_subtype->R3783_subtype;
}}}}
    /* SELECT one parent_object RELATED BY population->element[R3784.has current]->markable[R3786]->object[R3783] */
    parent_object = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_object_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_object = (masl_object *) R3786_subtype->R3783_subtype;
}}}}
    /* IF ( ( not_empty parent_domain and empty parent_terminator ) ) */
    if ( ( ( 0 != parent_domain ) && ( 0 == parent_terminator ) ) ) {
      /* SELECT any parent_terminator FROM INSTANCES OF terminator WHERE FALSE */
      parent_terminator = 0;
      /* SELECT any parent_object FROM INSTANCES OF object WHERE FALSE */
      parent_object = 0;
    }
    else if ( ( 0 != parent_terminator ) ) {
      /* SELECT any parent_domain FROM INSTANCES OF domain WHERE FALSE */
      parent_domain = 0;
      /* SELECT any parent_object FROM INSTANCES OF object WHERE FALSE */
      parent_object = 0;
    }
    else if ( ( 0 != parent_object ) ) {
      /* SELECT any parent_domain FROM INSTANCES OF domain WHERE FALSE */
      parent_domain = 0;
      /* SELECT any parent_terminator FROM INSTANCES OF terminator WHERE FALSE */
      parent_terminator = 0;
    }
    else {
      /* TRACE::log( flavor:failure, id:39, message:no parent for activity found ) */
      TRACE_log( "failure", 39, "no parent for activity found" );
    }
    /* SELECT any activity FROM INSTANCES OF activity WHERE FALSE */
    activity = 0;
    /* IF ( ( service == element ) ) */
    if ( ( Escher_strcmp( "service", element ) == 0 ) ) {
      /* ASSIGN activity = service::populate(deferred_relationship:value[3], instance:value[2], name:value[1], parent_domain:parent_domain, parent_object:parent_object, parent_terminator:parent_terminator, visibility:value[0]) */
      activity = masl_service_op_populate(value[3], value[2], value[1], parent_domain, parent_object, parent_terminator, value[0]);
    }
    else if ( ( Escher_strcmp( "function", element ) == 0 ) ) {
      /* ASSIGN activity = function::populate(deferred_relationship:value[3], instance:value[2], name:value[1], parent_domain:parent_domain, parent_object:parent_object, parent_terminator:parent_terminator, visibility:value[0]) */
      activity = masl_function_op_populate(value[3], value[2], value[1], parent_domain, parent_object, parent_terminator, value[0]);
    }
    /* SELECT one new_element RELATED BY activity->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != activity ) {
    masl_markable * markable_R3783 = activity->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "parameter", element ) == 0 ) ) {
    masl_parameter * parameter;masl_element * new_element=0;masl_parameter * sibling_parameter=0;masl_activity * parent_activity=0;
    /* SELECT one parent_activity RELATED BY population->element[R3784.has current]->markable[R3786]->activity[R3783] */
    parent_activity = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_activity_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_activity = (masl_activity *) R3786_subtype->R3783_subtype;
}}}}
    /* SELECT one sibling_parameter RELATED BY population->element[R3784.has current]->unmarkable[R3786]->parameter[R3788] */
    sibling_parameter = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_unmarkable * R3786_subtype = (masl_unmarkable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_unmarkable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_parameter_CLASS_NUMBER == R3786_subtype->R3788_object_id ) )    sibling_parameter = (masl_parameter *) R3786_subtype->R3788_subtype;
}}}}
    /* IF ( not_empty sibling_parameter ) */
    if ( ( 0 != sibling_parameter ) ) {
      /* SELECT any parent_activity FROM INSTANCES OF activity WHERE FALSE */
      parent_activity = 0;
    }
    else if ( ( 0 != parent_activity ) ) {
      /* SELECT any sibling_parameter FROM INSTANCES OF parameter WHERE FALSE */
      sibling_parameter = 0;
    }
    /* ASSIGN parameter = parameter::populate(direction:value[1], name:value[0], parent_activity:parent_activity, sibling_parameter:sibling_parameter) */
    parameter = masl_parameter_op_populate(value[1], value[0], parent_activity, sibling_parameter);
    /* SELECT one new_element RELATED BY parameter->unmarkable[R3788]->element[R3786] */
    new_element = 0;
    {    if ( 0 != parameter ) {
    masl_unmarkable * unmarkable_R3788 = parameter->unmarkable_R3788;
    if ( 0 != unmarkable_R3788 ) {
    new_element = unmarkable_R3788->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "attribute", element ) == 0 ) ) {
    masl_attribute * attribute;masl_element * new_element=0;masl_object * parent_object=0;
    /* SELECT one parent_object RELATED BY population->element[R3784.has current]->markable[R3786]->object[R3783] */
    parent_object = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_object_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_object = (masl_object *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN attribute = attribute::populate(defaultvalue:value[3], name:value[0], object:parent_object, preferred:value[1], unique:value[2]) */
    attribute = masl_attribute_op_populate(value[3], value[0], parent_object, value[1], value[2]);
    /* SELECT one new_element RELATED BY attribute->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != attribute ) {
    masl_markable * markable_R3783 = attribute->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "referential", element ) == 0 ) ) {
    masl_referential * p;c_t rolephrase[ESCHER_SYS_MAX_STRING_LEN];c_t attr[ESCHER_SYS_MAX_STRING_LEN];c_t obj[ESCHER_SYS_MAX_STRING_LEN];c_t roleOrObj[ESCHER_SYS_MAX_STRING_LEN];c_t relationship_name[ESCHER_SYS_MAX_STRING_LEN];c_t domain_name[ESCHER_SYS_MAX_STRING_LEN];masl_attribute * referred_to=0;masl_object * target_object=0;masl_relationship * relationship=0;masl_domain * parent_domain=0;masl_attribute * parent_attribute=0;masl_object * current_object=0;
    /* TRACE::log( flavor:levi, id:99, message:referential called ) */
    TRACE_log( "levi", 99, "referential called" );
    /* ASSIGN domain_name = value[1] */
    Escher_strcpy( domain_name, value[1] );
    /* ASSIGN relationship_name = value[0] */
    Escher_strcpy( relationship_name, value[0] );
    /* ASSIGN roleOrObj = value[2] */
    Escher_strcpy( roleOrObj, value[2] );
    /* ASSIGN obj = value[3] */
    Escher_strcpy( obj, value[3] );
    /* ASSIGN attr = value[4] */
    Escher_strcpy( attr, value[4] );
    /* SELECT any current_object RELATED BY population->element[R3789.has active]->markable[R3786]->object[R3783] */
    current_object = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3789_has_active;
    Escher_Iterator_s ielement_R3789_has_active;
    Escher_IteratorReset( &ielement_R3789_has_active, &population->element_R3789_has_active );
    while ( ( 0 == current_object ) && ( 0 != ( element_R3789_has_active = (masl_element *) Escher_IteratorNext( &ielement_R3789_has_active ) ) ) ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3789_has_active->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3789_has_active ) && ( masl_markable_CLASS_NUMBER == element_R3789_has_active->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_object_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    current_object = (masl_object *) R3786_subtype->R3783_subtype;
}}}}
    /* SELECT any parent_domain FROM INSTANCES OF domain WHERE FALSE */
    parent_domain = 0;
    /* IF ( (  == domain_name ) ) */
    if ( ( Escher_strcmp( "", domain_name ) == 0 ) ) {
      /* SELECT any parent_domain RELATED BY population->element[R3789.has active]->markable[R3786]->domain[R3783] */
      parent_domain = 0;
      {      if ( 0 != population ) {
      masl_element * element_R3789_has_active;
      Escher_Iterator_s ielement_R3789_has_active;
      Escher_IteratorReset( &ielement_R3789_has_active, &population->element_R3789_has_active );
      while ( ( 0 == parent_domain ) && ( 0 != ( element_R3789_has_active = (masl_element *) Escher_IteratorNext( &ielement_R3789_has_active ) ) ) ) {
      masl_markable * R3786_subtype = (masl_markable *) element_R3789_has_active->R3786_subtype;
      if ( 0 != R3786_subtype )      if ( ( 0 != element_R3789_has_active ) && ( masl_markable_CLASS_NUMBER == element_R3789_has_active->R3786_object_id ) ) {
      if ( ( 0 != R3786_subtype ) && ( masl_domain_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )      parent_domain = (masl_domain *) R3786_subtype->R3783_subtype;
}}}}
    }
    else {
      /* SELECT any parent_domain FROM INSTANCES OF domain WHERE ( SELECTED.name == domain_name ) */
      parent_domain = 0;
      { masl_domain * selected;
        Escher_Iterator_s iterparent_domainmasl_domain;
        Escher_IteratorReset( &iterparent_domainmasl_domain, &pG_masl_domain_extent.active );
        while ( (selected = (masl_domain *) Escher_IteratorNext( &iterparent_domainmasl_domain )) != 0 ) {
          if ( ( Escher_strcmp( selected->name, domain_name ) == 0 ) ) {
            parent_domain = selected;
            break;
          }
        }
      }
    }
    /* SELECT any relationship FROM INSTANCES OF relationship WHERE FALSE */
    relationship = 0;
    /* IF ( not_empty parent_domain ) */
    if ( ( 0 != parent_domain ) ) {
      /* SELECT any relationship RELATED BY parent_domain->relationship[R3712] WHERE ( ( SELECTED.name == relationship_name ) ) */
      relationship = 0;
      if ( 0 != parent_domain ) {
        masl_relationship * selected;
        Escher_Iterator_s irelationship_R3712;
        Escher_IteratorReset( &irelationship_R3712, &parent_domain->relationship_R3712 );
        while ( 0 != ( selected = (masl_relationship *) Escher_IteratorNext( &irelationship_R3712 ) ) ) {
          if ( ( Escher_strcmp( selected->name, relationship_name ) == 0 ) ) {
            relationship = selected;
            break;
      }}}
    }
    /* ASSIGN rolephrase =  */
    Escher_strcpy( rolephrase, "" );
    /* SELECT any target_object FROM INSTANCES OF object WHERE FALSE */
    target_object = 0;
    /* IF ( not_empty relationship ) */
    if ( ( 0 != relationship ) ) {
      masl_participation * participation=0;
      /* SELECT one participation RELATED BY relationship->participation[R3713] */
      participation = ( 0 != relationship ) ? relationship->participation_R3713_engages : 0;
      /* IF ( ( (  == roleOrObj ) and (  == obj ) ) ) */
      if ( ( ( Escher_strcmp( "", roleOrObj ) == 0 ) && ( Escher_strcmp( "", obj ) == 0 ) ) ) {
        /* SELECT one target_object RELATED BY participation->object[R3714] */
        target_object = ( 0 != participation ) ? participation->object_R3714_one : 0;
        /* IF ( ( target_object == current_object ) ) */
        if ( ( target_object == current_object ) ) {
          /* SELECT any target_object RELATED BY participation->object[R3720] */
          target_object = ( 0 != participation ) ? (masl_object *) Escher_SetGetAny( &participation->object_R3720_other ) : 0;
        }
      }
      else if ( ( Escher_strcmp( "", roleOrObj ) != 0 ) ) {
        /* IF ( ( participation.otherphrase == roleOrObj ) ) */
        if ( ( Escher_strcmp( participation->otherphrase, roleOrObj ) == 0 ) ) {
          /* ASSIGN rolephrase = participation.otherphrase */
          Escher_strcpy( rolephrase, participation->otherphrase );
          /* SELECT one target_object RELATED BY participation->object[R3714] */
          target_object = ( 0 != participation ) ? participation->object_R3714_one : 0;
        }
        else if ( ( Escher_strcmp( participation->onephrase, roleOrObj ) == 0 ) ) {
          /* ASSIGN rolephrase = participation.onephrase */
          Escher_strcpy( rolephrase, participation->onephrase );
          /* IF ( (  != obj ) ) */
          if ( ( Escher_strcmp( "", obj ) != 0 ) ) {
            /* SELECT any target_object RELATED BY participation->object[R3720] WHERE ( ( SELECTED.name == obj ) ) */
            target_object = 0;
            if ( 0 != participation ) {
              masl_object * selected;
              Escher_Iterator_s iobject_R3720_other;
              Escher_IteratorReset( &iobject_R3720_other, &participation->object_R3720_other );
              while ( 0 != ( selected = (masl_object *) Escher_IteratorNext( &iobject_R3720_other ) ) ) {
                if ( ( Escher_strcmp( selected->name, obj ) == 0 ) ) {
                  target_object = selected;
                  break;
            }}}
          }
          else {
            /* SELECT any target_object RELATED BY participation->object[R3720] */
            target_object = ( 0 != participation ) ? (masl_object *) Escher_SetGetAny( &participation->object_R3720_other ) : 0;
          }
        }
        else {
          /* SELECT one target_object RELATED BY participation->object[R3714] WHERE ( ( SELECTED.name == roleOrObj ) ) */
          {target_object = 0;
          {masl_object * selected = ( 0 != participation ) ? participation->object_R3714_one : 0;
          if ( ( 0 != selected ) && ( Escher_strcmp( selected->name, roleOrObj ) == 0 ) ) {
            target_object = selected;
          }}}
          /* IF ( empty target_object ) */
          if ( ( 0 == target_object ) ) {
            /* SELECT any target_object RELATED BY participation->object[R3720] WHERE ( ( SELECTED.name == roleOrObj ) ) */
            target_object = 0;
            if ( 0 != participation ) {
              masl_object * selected;
              Escher_Iterator_s iobject_R3720_other;
              Escher_IteratorReset( &iobject_R3720_other, &participation->object_R3720_other );
              while ( 0 != ( selected = (masl_object *) Escher_IteratorNext( &iobject_R3720_other ) ) ) {
                if ( ( Escher_strcmp( selected->name, roleOrObj ) == 0 ) ) {
                  target_object = selected;
                  break;
            }}}
          }
        }
      }
      else {
      }
    }
    /* SELECT any referred_to FROM INSTANCES OF attribute WHERE FALSE */
    referred_to = 0;
    /* IF ( not_empty target_object ) */
    if ( ( 0 != target_object ) ) {
      /* SELECT any referred_to RELATED BY target_object->attribute[R3709] WHERE ( ( SELECTED.name == attr ) ) */
      referred_to = 0;
      if ( 0 != target_object ) {
        masl_attribute * selected;
        Escher_Iterator_s iattribute_R3709_is_characterized_by;
        Escher_IteratorReset( &iattribute_R3709_is_characterized_by, &target_object->attribute_R3709_is_characterized_by );
        while ( 0 != ( selected = (masl_attribute *) Escher_IteratorNext( &iattribute_R3709_is_characterized_by ) ) ) {
          if ( ( Escher_strcmp( selected->name, attr ) == 0 ) ) {
            referred_to = selected;
            break;
      }}}
    }
    /* IF ( empty referred_to ) */
    if ( ( 0 == referred_to ) ) {
      /* ASSIGN referred_to = attribute::populate(defaultvalue:, name:attr, object:target_object, preferred:, unique:) */
      referred_to = masl_attribute_op_populate("", attr, target_object, "", "");
    }
    /* SELECT one parent_attribute RELATED BY population->element[R3784.has current]->markable[R3786]->attribute[R3783] */
    parent_attribute = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_attribute_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_attribute = (masl_attribute *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN p = referential::populate(referred_to:referred_to, referring:parent_attribute, relationship:relationship, rolephrase:rolephrase) */
    p = masl_referential_op_populate(referred_to, parent_attribute, relationship, rolephrase);
  }
  else if ( ( Escher_strcmp( "typeref", element ) == 0 ) ) {
    masl_typeref * p;masl_domain * parent_domain=0;masl_attribute * parent_attribute=0;masl_parameter * parent_parameter=0;masl_function * parent_function=0;
    /* SELECT one parent_function RELATED BY population->element[R3784.has current]->markable[R3786]->activity[R3783]->function[R3704] */
    parent_function = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    masl_activity * R3783_subtype = (masl_activity *) R3786_subtype->R3783_subtype;
    if ( 0 != R3783_subtype )    if ( ( 0 != R3786_subtype ) && ( masl_activity_CLASS_NUMBER == R3786_subtype->R3783_object_id ) ) {
    if ( ( 0 != R3783_subtype ) && ( masl_function_CLASS_NUMBER == R3783_subtype->R3704_object_id ) )    parent_function = (masl_function *) R3783_subtype->R3704_subtype;
}}}}}
    /* SELECT one parent_parameter RELATED BY population->element[R3784.has current]->unmarkable[R3786]->parameter[R3788] */
    parent_parameter = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_unmarkable * R3786_subtype = (masl_unmarkable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_unmarkable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_parameter_CLASS_NUMBER == R3786_subtype->R3788_object_id ) )    parent_parameter = (masl_parameter *) R3786_subtype->R3788_subtype;
}}}}
    /* SELECT one parent_attribute RELATED BY population->element[R3784.has current]->markable[R3786]->attribute[R3783] */
    parent_attribute = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_attribute_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_attribute = (masl_attribute *) R3786_subtype->R3783_subtype;
}}}}
    /* IF ( ( not_empty parent_function and empty parent_parameter ) ) */
    if ( ( ( 0 != parent_function ) && ( 0 == parent_parameter ) ) ) {
      /* SELECT any parent_parameter FROM INSTANCES OF parameter WHERE FALSE */
      parent_parameter = 0;
      /* SELECT any parent_attribute FROM INSTANCES OF attribute WHERE FALSE */
      parent_attribute = 0;
    }
    else if ( ( 0 != parent_parameter ) ) {
      /* SELECT any parent_attribute FROM INSTANCES OF attribute WHERE FALSE */
      parent_attribute = 0;
      /* SELECT any parent_function FROM INSTANCES OF function WHERE FALSE */
      parent_function = 0;
    }
    else if ( ( 0 != parent_attribute ) ) {
      /* SELECT any parent_parameter FROM INSTANCES OF parameter WHERE FALSE */
      parent_parameter = 0;
      /* SELECT any parent_function FROM INSTANCES OF function WHERE FALSE */
      parent_function = 0;
    }
    else {
      /* TRACE::log( flavor:failure, id:39, message:no parent for typeref ) */
      TRACE_log( "failure", 39, "no parent for typeref" );
    }
    /* SELECT any parent_domain RELATED BY population->element[R3789.has active]->markable[R3786]->domain[R3783] */
    parent_domain = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3789_has_active;
    Escher_Iterator_s ielement_R3789_has_active;
    Escher_IteratorReset( &ielement_R3789_has_active, &population->element_R3789_has_active );
    while ( ( 0 == parent_domain ) && ( 0 != ( element_R3789_has_active = (masl_element *) Escher_IteratorNext( &ielement_R3789_has_active ) ) ) ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3789_has_active->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3789_has_active ) && ( masl_markable_CLASS_NUMBER == element_R3789_has_active->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_domain_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_domain = (masl_domain *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN p = typeref::populate(body:value[0], domain:parent_domain, name:, parent_attribute:parent_attribute, parent_function:parent_function, parent_parameter:parent_parameter) */
    p = masl_typeref_op_populate(value[0], parent_domain, "", parent_attribute, parent_function, parent_parameter);
  }
  else if ( ( Escher_strcmp( "transitiontable", element ) == 0 ) ) {
    masl_state_machine * state_machine;masl_element * new_element=0;masl_object * parent_object=0;
    /* SELECT one parent_object RELATED BY population->element[R3784.has current]->markable[R3786]->object[R3783] */
    parent_object = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_object_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_object = (masl_object *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN state_machine = state_machine::populate(object:parent_object, type:value[0]) */
    state_machine = masl_state_machine_op_populate(parent_object, value[0]);
    /* SELECT one new_element RELATED BY state_machine->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != state_machine ) {
    masl_markable * markable_R3783 = state_machine->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "state", element ) == 0 ) ) {
    masl_state * state;masl_object * parent_object=0;
    /* SELECT one parent_object RELATED BY population->element[R3784.has current]->markable[R3786]->object[R3783] */
    parent_object = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_object_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_object = (masl_object *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN state = state::populate(name:value[0], object:parent_object, type:value[1]) */
    state = masl_state_op_populate(value[0], parent_object, value[1]);
  }
  else if ( ( Escher_strcmp( "event", element ) == 0 ) ) {
    masl_event * event;masl_element * new_element=0;masl_object * parent_object=0;
    /* SELECT one parent_object RELATED BY population->element[R3784.has current]->markable[R3786]->object[R3783] */
    parent_object = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_object_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_object = (masl_object *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN event = event::populate(name:value[0], object:parent_object, type:value[1]) */
    event = masl_event_op_populate(value[0], parent_object, value[1]);
    /* SELECT one new_element RELATED BY event->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != event ) {
    masl_markable * markable_R3783 = event->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "transition", element ) == 0 ) ) {
    masl_cell * c;masl_state_machine * parent_state_machine=0;
    /* SELECT one parent_state_machine RELATED BY population->element[R3784.has current]->markable[R3786]->state_machine[R3783] */
    parent_state_machine = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_state_machine_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_state_machine = (masl_state_machine *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN c = cell::populate(endstate:value[2], event:value[1], startstate:value[0], statemachine:parent_state_machine) */
    c = masl_cell_op_populate(value[2], value[1], value[0], parent_state_machine);
  }
  else if ( ( ( ( Escher_strcmp( "regularrel", element ) == 0 ) || ( Escher_strcmp( "associative", element ) == 0 ) ) || ( Escher_strcmp( "subsuper", element ) == 0 ) ) ) {
    masl_relationship * relationship=0;masl_element * new_element=0;masl_element * curr=0;masl_domain * parent_domain=0;
    /* SELECT any parent_domain RELATED BY population->element[R3789.has active]->markable[R3786]->domain[R3783] */
    parent_domain = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3789_has_active;
    Escher_Iterator_s ielement_R3789_has_active;
    Escher_IteratorReset( &ielement_R3789_has_active, &population->element_R3789_has_active );
    while ( ( 0 == parent_domain ) && ( 0 != ( element_R3789_has_active = (masl_element *) Escher_IteratorNext( &ielement_R3789_has_active ) ) ) ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3789_has_active->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3789_has_active ) && ( masl_markable_CLASS_NUMBER == element_R3789_has_active->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_domain_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_domain = (masl_domain *) R3786_subtype->R3783_subtype;
}}}}
    /* SELECT one curr RELATED BY population->element[R3784.has current] */
    curr = ( 0 != population ) ? population->element_R3784_has_current : 0;
    /* TRACE::log( flavor:levi, id:99, message:( curr:   + curr.name ) ) */
    TRACE_log( "levi", 99, Escher_stradd( "curr:  ", curr->name ) );
    /* TRACE::log( flavor:levi, id:99, message:( parent_domain:   + parent_domain.name ) ) */
    TRACE_log( "levi", 99, Escher_stradd( "parent_domain:  ", parent_domain->name ) );
    /* SELECT any relationship FROM INSTANCES OF relationship WHERE FALSE */
    relationship = 0;
    /* IF ( ( regularrel == element ) ) */
    if ( ( Escher_strcmp( "regularrel", element ) == 0 ) ) {
      /* ASSIGN relationship = regularrel::populate(domain:parent_domain, name:value[0]) */
      relationship = masl_regularrel_op_populate(parent_domain, value[0]);
    }
    else if ( ( Escher_strcmp( "associative", element ) == 0 ) ) {
      /* ASSIGN relationship = associative::populate(domain:parent_domain, name:value[0], using:value[1]) */
      relationship = masl_associative_op_populate(parent_domain, value[0], value[1]);
    }
    else if ( ( Escher_strcmp( "subsuper", element ) == 0 ) ) {
      /* ASSIGN relationship = subsuper::populate(domain:parent_domain, name:value[0]) */
      relationship = masl_subsuper_op_populate(parent_domain, value[0]);
    }
    else {
      /* TRACE::log( flavor:levi, id:99, message:this is very bad ) */
      TRACE_log( "levi", 99, "this is very bad" );
    }
    /* SELECT one new_element RELATED BY relationship->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != relationship ) {
    masl_markable * markable_R3783 = relationship->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "participation", element ) == 0 ) ) {
    masl_participation * participation;masl_element * new_element=0;masl_participation * parent_participation=0;masl_relationship * parent_relationship=0;
    /* SELECT any parent_relationship RELATED BY population->element[R3789.has active]->markable[R3786]->relationship[R3783] */
    parent_relationship = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3789_has_active;
    Escher_Iterator_s ielement_R3789_has_active;
    Escher_IteratorReset( &ielement_R3789_has_active, &population->element_R3789_has_active );
    while ( ( 0 == parent_relationship ) && ( 0 != ( element_R3789_has_active = (masl_element *) Escher_IteratorNext( &ielement_R3789_has_active ) ) ) ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3789_has_active->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3789_has_active ) && ( masl_markable_CLASS_NUMBER == element_R3789_has_active->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_relationship_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_relationship = (masl_relationship *) R3786_subtype->R3783_subtype;
}}}}
    /* SELECT one parent_participation RELATED BY population->element[R3784.has current]->unmarkable[R3786]->participation[R3788] */
    parent_participation = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_unmarkable * R3786_subtype = (masl_unmarkable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_unmarkable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_participation_CLASS_NUMBER == R3786_subtype->R3788_object_id ) )    parent_participation = (masl_participation *) R3786_subtype->R3788_subtype;
}}}}
    /* ASSIGN participation = participation::populate(conditionality:value[2], fromobject:value[0], multiplicity:value[3], participation:parent_participation, phrase:value[1], relationship:parent_relationship, toobject:value[4]) */
    participation = masl_participation_op_populate(value[2], value[0], value[3], parent_participation, value[1], parent_relationship, value[4]);
    /* SELECT one new_element RELATED BY participation->unmarkable[R3788]->element[R3786] */
    new_element = 0;
    {    if ( 0 != participation ) {
    masl_unmarkable * unmarkable_R3788 = participation->unmarkable_R3788;
    if ( 0 != unmarkable_R3788 ) {
    new_element = unmarkable_R3788->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "type", element ) == 0 ) ) {
    masl_type * type;masl_element * new_element=0;masl_domain * parent_domain=0;
    /* SELECT one parent_domain RELATED BY population->element[R3784.has current]->markable[R3786]->domain[R3783] */
    parent_domain = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_markable * R3786_subtype = (masl_markable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_domain_CLASS_NUMBER == R3786_subtype->R3783_object_id ) )    parent_domain = (masl_domain *) R3786_subtype->R3783_subtype;
}}}}
    /* ASSIGN type = type::populate(body:value[2], domain:parent_domain, name:value[0], visibility:value[1]) */
    type = masl_type_op_populate(value[2], parent_domain, value[0], value[1]);
    /* SELECT one new_element RELATED BY type->markable[R3783]->element[R3786] */
    new_element = 0;
    {    if ( 0 != type ) {
    masl_markable * markable_R3783 = type->markable_R3783;
    if ( 0 != markable_R3783 ) {
    new_element = markable_R3783->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "pragma", element ) == 0 ) ) {
    masl_pragma * pragma;masl_element * new_element=0;masl_markable * markable=0;
    /* SELECT one markable RELATED BY population->element[R3784.has current]->markable[R3786] */
    markable = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    if ( ( 0 != element_R3784_has_current ) && ( masl_markable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) )    markable = (masl_markable *) element_R3784_has_current->R3786_subtype;
}}}
    /* ASSIGN pragma = pragma::populate(element:markable, list:value[1], name:value[0]) */
    pragma = masl_pragma_op_populate(markable, value[1], value[0]);
    /* SELECT one new_element RELATED BY pragma->unmarkable[R3788]->element[R3786] */
    new_element = 0;
    {    if ( 0 != pragma ) {
    masl_unmarkable * unmarkable_R3788 = pragma->unmarkable_R3788;
    if ( 0 != unmarkable_R3788 ) {
    new_element = unmarkable_R3788->element_R3786;
}}}
    /* population.push_element( new_element:new_element ) */
    masl_population_op_push_element( population,  new_element );
  }
  else if ( ( Escher_strcmp( "pragmaitem", element ) == 0 ) ) {
    masl_pragma * parent_pragma=0;
    /* SELECT one parent_pragma RELATED BY population->element[R3784.has current]->unmarkable[R3786]->pragma[R3788] */
    parent_pragma = 0;
    {    if ( 0 != population ) {
    masl_element * element_R3784_has_current = population->element_R3784_has_current;
    if ( 0 != element_R3784_has_current ) {
    masl_unmarkable * R3786_subtype = (masl_unmarkable *) element_R3784_has_current->R3786_subtype;
    if ( 0 != R3786_subtype )    if ( ( 0 != element_R3784_has_current ) && ( masl_unmarkable_CLASS_NUMBER == element_R3784_has_current->R3786_object_id ) ) {
    if ( ( 0 != R3786_subtype ) && ( masl_pragma_CLASS_NUMBER == R3786_subtype->R3788_object_id ) )    parent_pragma = (masl_pragma *) R3786_subtype->R3788_subtype;
}}}}
    /* pragma_item::populate( pragma:parent_pragma, value:value[0] ) */
    masl_pragma_item_op_populate( parent_pragma, value[0] );
  }
  else {
    /* TRACE::log( flavor:failure, id:39, message:( unrecognized element:   + element ) ) */
    TRACE_log( "failure", 39, Escher_stradd( "unrecognized element:  ", element ) );
  }
}

/*
 * instance operation:  push_element
 */
void
masl_population_op_push_element( masl_population * self, masl_element * p_new_element )
{
  masl_element * new_element;masl_element * current_element=0;
  /* ASSIGN new_element = PARAM.new_element */
  new_element = p_new_element;
  /* TRACE::log( flavor:levi, id:99, message:( pushing stack:  + new_element.name ) ) */
  TRACE_log( "levi", 99, Escher_stradd( "pushing stack: ", new_element->name ) );
  /* SELECT one current_element RELATED BY self->element[R3784.has current] */
  current_element = ( 0 != self ) ? self->element_R3784_has_current : 0;
  /* IF ( ( current_element == new_element ) ) */
  if ( ( current_element == new_element ) ) {
    /* TRACE::log( flavor:levi, id:99, message:can't push same element twice ) */
    TRACE_log( "levi", 99, "can't push same element twice" );
  }
  else {
    /* UNRELATE self FROM current_element ACROSS R3784 */
    masl_element_R3784_Unlink_has_current( self, current_element );
    /* RELATE self TO new_element ACROSS R3784 */
    masl_element_R3784_Link_has_current( self, new_element );
    /* RELATE new_element TO current_element ACROSS R3787 */
    masl_element_R3787_Link_child_of( new_element, current_element );
    /* RELATE self TO new_element ACROSS R3789 */
    masl_element_R3789_Link_has_active( self, new_element );
  }
}


/*----------------------------------------------------------------------------
 * Operation action methods implementation for the following class:
 *
 * Class:      population  (population)
 * Component:  masl
 *--------------------------------------------------------------------------*/
/*
 * Statically allocate space for the instance population for this class.
 * Allocate space for the class instance and its attribute values.
 * Depending upon the collection scheme, allocate containoids (collection
 * nodes) for gathering instances into free and active extents.
 */
static Escher_SetElement_s masl_population_container[ masl_population_MAX_EXTENT_SIZE ];
static masl_population masl_population_instances[ masl_population_MAX_EXTENT_SIZE ];
Escher_Extent_t pG_masl_population_extent = {
  {0}, {0}, &masl_population_container[ 0 ],
  (Escher_iHandle_t) &masl_population_instances,
  sizeof( masl_population ), 0, masl_population_MAX_EXTENT_SIZE
  };

