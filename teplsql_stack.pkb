create or replace
package body teplsql_stack
as
    g_code_owner   CONSTANT oddgen_types.key_type := 'Code Owner';
    g_data_type    CONSTANT oddgen_types.key_type := 'Data Type';
    g_package_name CONSTANT oddgen_types.key_type := 'Package Name';
   
   function generate_stack( pkg_name in varchar2
                             ,code_schema in varchar2 default USER
                             ,data_type in varchar2 default 'NUMBER'
                             ,indention_string in varchar2 default '    '
                            ) return clob
    as
        buffer_clob      clob;
        p_vars           teplsql.t_assoc_array;
    begin
        if pkg_name is null
        then
            raise invalid_number;
        else
            p_vars( 'pkg_name' ) := pkg_name;
        end if;

        p_vars( teplsql.g_set_indention_string ) := indention_string;
        p_vars( 'schema' )                       := nvl( code_schema, USER);
        p_vars( 'stack_data_type_desc' )         := nvl( data_type, 'NUMBER' );
        
        buffer_clob := teplsql.process_build( p_vars, 'build.stack' , 'TEPLSQL_STACK', 'PACKAGE' );
        
        return buffer_clob;
    end;
    
    function generate( in_node in oddgen_types.r_node_type )
        return clob
    as
        buffer_clob      clob;
        
        pkg_name         varchar2(130 byte);
        schema_name      varchar2(130 byte);
        data_type        varchar2(100);
        
        invalid_user        exception;
        invalid_object_name exception;
        
        pragma exception_init( invalid_user, -44001 );
        pragma exception_init( invalid_object_name, -44004 );
    begin
        -- assert Code Owner
        <<assert_code_owner>>
        begin
            if upper( in_node.params(g_code_owner) ) = '#OWNER#'
            then
                schema_name := '#OWNER#';
            else
                schema_name := dbms_assert.schema_name( nvl( in_node.params(g_code_owner), USER) );
            end if;
        exception
            when invalid_user then
                 buffer_clob := buffer_clob || 'Code Owner name is not a currently known schema [' || in_node.params(g_code_owner) || ']' || chr(10);
        end;
        
        -- assert Package Name
        <<assert_package_name>>
        begin
            pkg_name    := dbms_assert.qualified_sql_name( in_node.params(g_package_name) );
            
            -- validate that it is not a "reserved word"
        exception
            when invalid_object_name then
                 buffer_clob := buffer_clob || 'Package name is invalid [' || in_node.params(g_package_name) || ']' || chr(10)
                                || '  Try surrounding in double quotes ( " )' || chr(10);
        end;

        -- assert Data Type [TODO]
        <<assert_data_type>>
        declare
            is_valid boolean := false;
        begin
            data_type   := nvl( in_node.params(g_data_type), 'NUMBER' );

            -- check internal data types
            
            -- check if it is a UDT
            
            -- check if it is a PL/SQL Type (valid for Package not UDT)
        end;
        
        -- generate code
        if buffer_clob is null
        then
            buffer_clob := generate_stack(  pkg_name => pkg_name
                                           ,code_schema => schema_name
                                           ,data_type   => data_type
                                           ,indention_string => '    '
                                        );
        end if;
        
        return buffer_clob;
    end;

    function get_name return varchar2
    as
    begin
        return 'Make-A-Stack';
    end;
    
    function get_nodes(
        in_parent_node_id in oddgen_types.key_type default null
     ) return oddgen_types.t_node_type
    as
        a_node oddgen_types.r_node_type;
    begin
        a_node.id              := 10;
        a_node.name            := 'Custom';
        a_node.leaf            := true;
        a_node.generatable     := true;
        a_node.multiselectable := false;
        
        a_node.params(g_code_owner)   := USER;
        a_node.params(g_package_name) := 'STACK_PKG';
        a_node.params(g_data_type)    := 'NUMBER';

        return oddgen_types.t_node_type( a_node );
    end;

    function get_ordered_params return oddgen_types.t_value_type
    as
    begin
        return oddgen_types.t_value_type( g_code_owner, g_package_name, g_data_type);
    end;


$if false $then
<%@ template( template_name=build.stack, build=make ) %>
<%@ extends(package, stack ) %>
    <%@ block( documentation ) %>/**
* STACK for data type "${stack_data_type_desc}"
*
* @headcom
*/
<%@ enblock %>
    <%@ block( name ) %>${pkg_name}<%@ enblock %>
------------ FUNCTIONS -------------
<%@ extends(procedure, push )%>
    <%@ block( documentation ) %>/*
* Appends an element to the top of the Stack
* (initializes the stack as needed)
*
* @param  dat    element to be added to the Stack
*/
<%@ enblock %>
    <%@ block( parameters ) %>dat in <%@ include( ${super.super}.plsql-type.stack_t.name ) %><%@ enblock %>
    <%@ block( bdy ) %><%@ include( ${super}.private.assert.name ) %>;

<%@ include( ${super.super}.variable.stack_buffer.name ) %>.extend;

<%@ include( ${super.super}.variable.stack_buffer.name ) %>( <%@ include( ${super.super}.variable.stack_buffer.name ) %>.count ) := dat;
<%@ enblock %>
<%@ enextends %>
--------------------------------
<%@ extends(procedure, clear_stack )%>
    <%@ block( documentation ) %>/*
* clears the stack.
* (initializes the stack as needed)
*/
<%@ enblock %>
    <%@ block( bdy ) %><%@ include( ${super.super}.variable.stack_buffer.name ) %>.delete;<%@ enblock %>
<%@ enextends %>
--------------------------------
<%@ extends(procedure, getSize )%>
    <%@ block( documentation ) %>/*
* returns the number of elements in the stack
* (initializes the stack as needed)
*
* @returns  number of elements
*/
<%@ enblock %>
    <%@ block( return-variable-type ) %>int<%@ enblock %>
    <%@ block( bdy ) %>
<%@ include( ${super}.private.assert.name ) %>;

<%@ include( ${this}.return-variable-name ) %> := <%@ include( ${super.super}.variable.stack_buffer.name ) %>.count;<%@ enblock %>
<%@ enextends %>
--------------------------------
<%@ extends(procedure, pop )%>
    <%@ block( documentation ) %>/*
* Returns the top element of the Stack and reduces the Stack by 1
*
* @returns    top element of the Stack
* @throws     no_data_found when Stack size is 0
*/
<%@ enblock %>
    <%@ block( return-variable-type ) %><%@ include( ${super.super}.plsql-type.stack_t.name ) %><%@ enblock %>
    <%@ block( bdy ) %><%@ include( ${this}.return-variable-name ) %> := peek;

-- delete last
<%@ include( ${super.super}.variable.stack_buffer.name ) %>.trim( 1 );
<%@ enblock %>
<%@ enextends %>
--------------------------------
<%@ extends(procedure, peek )%>
    <%@ block( documentation ) %>/*
* Returns the top element of the Stack.
*
* @returns    top element of the Stack
* @throws     no_data_found when Stack size is 0
*/
<%@ enblock %>
    <%@ block( return-variable-type ) %><%@ include( ${super.super}.plsql-type.stack_t.name ) %><%@ enblock %>
    <%@ block( bdy ) %>if <%@ include( ${super}.getSize.name ) %> = 0 then
    raise no_data_found;
end if;

<%@ include( ${this}.return-variable-name ) %> := <%@ include( ${super.super}.variable.stack_buffer.name ) %>( <%@ include( ${super.super}.variable.stack_buffer.name ) %>.count );
<%@ enblock %>
<%@ enextends %>
--------------------------------
<%@ extends(procedure, private.assert )%>
    <%@ block( documentation ) %>/*
* Ensures that the variable `stack_buffer` has been initialized
*/
<%@ enblock %>
    <%@ block( name ) %>assert<%@ enblock %>
    <%@ block( bdy ) %>if stack_buffer is null
then
    stack_buffer := new stack_nn();
end if;
<%@ enblock %>
<%@ enextends %>
------- Public Data Types ------
<%@ extends(plsql-type, stack_t )%>
    <%@ block( name ) %>stack_t<%@ enblock %>
    <%@ block( data-type ) %>${stack_data_type_desc}<%@ enblock %>
    <%@ block( nt-name ) %>stack_nn<%@ enblock %>
<%@ enextends %>
------- Private variables ------ (Package Helper Template is bugged)
<%@ extends( variable, stack_buffer ) %>
    <%@ block( name ) %>stack_buffer<%@ enblock %>
    <%@ block( data-type ) %><%@ include( ${super.super}.plsql-type.stack_t.nt-name ) %><%@ enblock %>
<%@ enextends %>
<%@ enextends %>
$end

end;