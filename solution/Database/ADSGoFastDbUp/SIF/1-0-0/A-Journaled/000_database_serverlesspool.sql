/*Operation isn't allowed for a replicated database
If you're trying to create SQL objects, users, or change permissions in a database, you might get errors like 
"Operation CREATE USER is not allowed for a replicated database." 
    This error is returned when you try to create objects in a database that's shared with Spark pool. 
    The databases that are replicated from Apache Spark pools are read only. 
    You can't create new objects into a replicated database by using T-SQL.

Create a separate database and reference the synchronized tables by using three-part names and cross-database queries.
*/

Declare @check int = 0
Set @check = (Select count(*) from sys.databases
where name = '$SynapseDatabaseName$')
if @check = 0
begin 
CREATE DATABASE [$SynapseDatabaseName$]
end
