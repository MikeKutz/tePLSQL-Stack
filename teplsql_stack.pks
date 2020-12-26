create or replace
package teplsql_stack
    authid current_user
as
    /**
    * This Package generates a Package that simulates a Stack
    *
    * Requires
    * - tePLSQL 2.0 or higher<br>
    *     (use current release since 2.0 has not been published yet)
    * - oddgen
    *
    * Dependant GitHub Projects
    * - tePLSQL : githuburl
    * - oddgen  : githuburl
    *
    * @headcom
    */
    
    /**
    * Primary Function that generates the code
    */
    function generate_stack( pkg_name in varchar2
                             ,code_schema in varchar2 default USER
                             ,data_type in varchar2 default 'NUMBER'
                             ,indention_string in varchar2 default '    '
                            ) return clob;

    /* ODDGEN interface
    *
    * generates the code when called via oddgen
    *   
    * @param in_node in oddgen_types.r_node_type
    * @return 
    */
    function generate( in_node in oddgen_types.r_node_type )
        return clob;
        
    /* ODDGEN interface
    * returns the name of the generator
    */
    function get_name return varchar2;

    function get_nodes(
        in_parent_node_id in oddgen_types.key_type default null
     ) return oddgen_types.t_node_type;

    function get_ordered_params return oddgen_types.t_value_type;
    

end;
/
