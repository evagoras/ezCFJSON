<cfscript>
param name="url.everything" default=true type="boolean";
param name="url.populate" default="struct" type="string";

cfinclude( template="data.cfm" );

user = new beans.basket.user();
user.populate( url.populate == "struct" ? struct : json );

writedump( user.toNative( everything = url.everything ) );
</cfscript>