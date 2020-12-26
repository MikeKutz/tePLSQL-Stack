# tePLSQL-Stack
tePLSQL template for creating a Stack

# Requires
- [oddgen](https://github.com/oddgen/oddgen)
- [tePLSQL](https://github.com/osalvador/tePLSQL) (use current)

# Parameters

# Usage

## oddgen
This will appear in your oddgen generator list's Database Server Generators as `Make-A-Stack`.  Right-click on `Custom` and choose `Generate...` to get a forum for customizations

| Parameter | Description
|-----------|------------
| Code Schema | Generated code will be for this schema.  This must exist or be `#OWNER#`
| Package Name | Name of the `PACKAGE` to be generated.
| Data Type | Data Type for individual elements of the Stack


## PL/SQL
Call the function `generate_stack` with the appropriate parameters

| Parameter | Req? | Default | Description
|-----------|------|---------|-------------
| `pkg_name` | Y | | Name of the `PACKAGE` to be generated.
| `code_schema` | N | `USER` | Generated code will be for this schema.  This must exist or be `#OWNER#`
| `data_type` | N | `'NUMBER'` | Data Type for individual elements of the Stack
| `indention_string` | N | `'    '` (4 spaces) | String to use for indention

