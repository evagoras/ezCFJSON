<cfscript>
param name="url.everything" default=true type="boolean";
param name="url.populate" default="struct" type="string";

cfinclude( template="data.cfm" );

user = new beans.basket.user();
switch ( url.populate)
{
	case "struct":
		user.populate( struct );
		break;
	case "json":
		user.populate( json );
		break;
	case "jsonminimum":
		user.populate( jsonminimum );
		break;
	case "query":
		user.populate( query );
		break;
}

writeoutput( user.toJson( everything = url.everything ) );
</cfscript>