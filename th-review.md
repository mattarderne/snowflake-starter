In my mind I'm kind of testing three core principles to see if they stand up to scrutiny. While there are many opinions on how to set up privileges, I think these should followed almost always: 
 - Don’t grant more than one custom role the ability to create objects in a single database.
 - Every custom role has to eventually roll up to sysadmin.
 - Never grant the custom database_owner roles to any other role except sysadmin.
 
 In your setup it looks like SysAdmin owns the databases, but has no privileges to the objects in the database. Does this present a problem for you? 
 
 I will usually do the following on any custom role:grant role <custom_role> to role sysadmin;
 Here is the documentation suggesting this best practice:
https://docs.snowflake.com/en/user-guide/security-access-control-configure.html#creating-a-role-hierarchy

Since role_ingest and role_transform can do anything in the database except drop the information schema and public (which I'm not sure can be dropped anyway?) is there a reason to not make them the owners of their respective databases?
You don't need to do this line since you just created the database and the only schemas are public and information_schema. And it *looks* like roles with any object grant already have implicit usage on these schemas. I'm honestly not sure how that works.
GRANT USAGE ON ALL SCHEMAS in DATABASE "RAW" to ROLE "ROLE_INGEST";

You may have a typo in your script. It looks like you're granting USAGE on RAW to the same role twice. I think the second line is redundant:
GRANT CREATE SCHEMA, MODIFY, MONITOR, USAGE ON DATABASE "RAW" TO ROLE "ROLE_INGEST";
GRANT USAGE ON DATABASE "RAW" TO ROLE "ROLE_INGEST";
You do the same thing with the ROLE_TRANSFORM


Have you thought about granting usage on future UDFs to role_report? I don't know if you use UDFs, but someone using your script might.

Is there a reason you quote all your object names to be uppercase? I usually don't use quotes since uppercased and quoted is the same as any casing unquoted, but I'm interested if there's a reason you do.

I like your alerts. I'm going to use those!

This is super subjective, but I prefer to put the database name in the role name in case I add databases. 

For example, we have one database for Fivetran, one for Stitch, and one for anything we load via Snowpipe or the CLI. 
I don't know that that's the right way but for each database we just have two roles - owner, and reader. This is explained a bit more here: https://trevorscode.com/toward-a-standard-model-for-snowflake-roles-and-privileges/. 
Overall, this looks really good. Very nice work! 

Also, one reason I give my readers a lot of privileges is that a lot of my readers are developers who need to know how things work - I want them to be able to describe and show and get_ddl() on all the objects. But I don't want them modifying anything.