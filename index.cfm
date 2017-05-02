<h1>ezCFJSON</h1>
<p>A (de)serializer for CF that works around the common issues found in CF, mainly dealing with type casting.</p>

<h2>Struct Examples</h2>
<ul>
	<li><a href="populate.cfm">Populate a complex Bean from CF</a></li>
	<li><a href="tojson.cfm">Serialize Complex Struct to JSON (including all the fields of the Beans regardless if they were populated or not)</a></li>
	<li><a href="tojson.cfm?everything=false">Serialize Complex Struct to JSON (just the populated fields)</a></li>
	<li><a href="tonative.cfm">Serialize Complex Struct to native CF Struct (including all the fields of the Beans regardless if they were populated or not)</a></li>
	<li><a href="tonative.cfm?everything=false">Serialize Complex Struct to native CF Struct (just the populated fields)</a></li>
</ul>

<h3>JSON string Examples</h3>
<ul>
	<li><a href="populate.cfm?populate=json">Populate a complex Bean from a JSON string</a></li>
	<li><a href="tojson.cfm?populate=json">Serialize Complex Struct to JSON (including all the fields of the Beans regardless if they were populated or not)</a></li>
	<li><a href="tojson.cfm?everything=false&populate=jsonminimum">Serialize Complex Struct to JSON (just the populated fields)</a></li>
	<li><a href="tonative.cfm?populate=json">Serialize Complex Struct to native CF Struct (including all the fields of the Beans regardless if they were populated or not)</a></li>
	<li><a href="tonative.cfm?everything=false&populate=jsonminimum">Serialize Complex Struct to native CF Struct (just the populated fields)</a></li>
</ul>

<h3>CF Query Examples</h3>
<ul>
	<li><a href="populate.cfm?populate=query">Populate a complex Bean from a CF Query</a></li>
	<li><a href="tojson.cfm?populate=query">Serialize Complex Struct to JSON (including all the fields of the Beans regardless if they were populated or not)</a></li>
	<li><a href="tojson.cfm?everything=false&populate=query">Serialize Complex Struct to JSON (just the populated fields)</a></li>
	<li><a href="tonative.cfm?populate=query">Serialize Complex Struct to native CF Struct (including all the fields of the Beans regardless if they were populated or not)</a></li>
	<li><a href="tonative.cfm?everything=false&populate=query">Serialize Complex Struct to native CF Struct (just the populated fields)</a></li>
</ul>