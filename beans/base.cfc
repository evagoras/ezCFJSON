component {


	public any function init() {
		// introspects and stores the properties of the Bean in categories
		variables.populatedProperties = [];
		variables.categorizedProperties = returnCategorizedProperties();
		variables.namedSimpleProperties = returnNamedSimpleProperties();
		return this;
	}


	/**
	 * @hint Return a JSON string of the populated bean
	 * @fields value of all/populated to return either everything or just the populated fields.
	 */
	public string function toJson( boolean everything = true ) {
		var payload = this.serialize( everything = everything );
		var jsonString = serializeJson( payload );
		return removeSTX( jsonString = jsonString );
	}


	/**
	 * @hint Return a CF Struct Native of the populated bean
	 * @fields value of all/populated to return either everything or just the populated fields.
	 */
	public struct function toNative( boolean everything = true ) {
		return deserializeJson( toJson( everything = everything ) );
	}


	/**
	 * @hint Can populate from a QUERY, a STRUCT or a JSON string
	 * @memento The data to populate with
	 */
	public void function populate( required any memento ) {
		var data = {};
		if ( isJson( memento ) ) {
			data = deserializeJson( memento );
		}
		if ( isQuery( memento ) ) {
			data = queryToStruct( memento );
		}
		if ( isStruct( memento ) ) {
			data = memento;
		}
		// populate all the properties in this Bean
		populateSimpleProperties( memento = data );
		populateOneToOneProperties( memento = data );
		populateOneToManyProperties( memento = data );
	}


	/**
	 * @hint Returns the Populated Bean as a STRUCT
	 */
	public struct function serialize( required boolean everything ) {
		var s = serializeSimpleProperties( everything = everything );
		s.putAll( serializeOneToOneProperties( everything = everything ) );
		s.putAll( serializeOneToManyProperties( everything = everything ) );
		return s;
	}


	/*
	 * -------------------------- PRIVATE METHODS --------------------------
	 */


	/**
	 * @hint Populates all the simple properties of the Bean
	 * @memento The data to populate with
	 */
	private void function populateSimpleProperties( required struct memento ) {
		var properties = variables.categorizedProperties[ "simple" ];
		// for every key in the memento payload
		for ( var mementoKey in memento ) {
			// try to find that key in the Bean properties
			for ( var property in properties ) {
				// if found
				if
				(
					(
						property.keyExists( "json:column" )
						&& len( property[ "json:column" ] )
						&& property[ "json:column" ] == mementoKey
					)
					||
					( property.name == mementoKey )
				)
				{
					// If the payload has a value then simply assign it to the property
					if ( memento.keyExists( mementoKey ) ) {
						// set the actual value
						_setProperty(
							property = property.name,
							value = memento[ mementoKey ]
						);
						// set the Java type based on the json:type property attribute
						setKeyJavaType( property.name );
					} else {
					// the payload value was a NULL
						_setPropertyAsNull( property = property.name );
					}
					variables.populatedProperties.append( property.name );
					break;
				}
			}
		}
	}


	/**
	 * @hint Populates all the one-to-one mapped properties of the Bean
	 * @memento The data to populate with
	 */
	private void function populateOneToOneProperties( required struct memento ) {
		// get all the one-to-one properties of this Bean
		var properties = variables.categorizedProperties[ "struct" ];
		for ( var mementoKey in memento ) {
			// try to find that key in the Bean properties
			for ( var property in properties ) {
				// if found
				if
				(
					(
						property.keyExists( "json:column" )
						&& len( property[ "json:column" ] )
						&& property[ "json:column" ] == mementoKey
					)
					||
					( property.name == mementoKey )
				)
				{
					if
					(
						memento.keyExists( mementoKey )
						&&
						isStruct( memento[ mementoKey ] ) == true
					)
					{
						// instantiate the linked Bean
						var bean = createObject( "component", property[ "json:cfc" ] ).init();
						// populate the Bean with the payload specific part
						bean.populate( memento[ mementoKey ] );
						// add the linked populated Bean to this Bean's specific property
						_setProperty(
							property = property.name,
							value = bean
						);
					} else {
					// the payload value was a NULL
						_setPropertyAsNull( property = property.name );
					}
					variables.populatedProperties.append( property.name );
					break;
				}
			}
		}
	}


	/**
	 * @hint Populates the one-to-many properties of the Bean
	 * @memento The data to populate with
	 */
	private void function populateOneToManyProperties( required struct memento ) {
		// get all the one-to-many properties of this Bean
		var properties = variables.categorizedProperties[ "array" ];
		var bean = "";
		var injectedBeans = [];
		for ( var mementoKey in memento ) {
			// try to find that key in the Bean properties
			for ( var property in properties ) {
				// if found
				if
				(
					(
						property.keyExists( "json:column" )
						&& len( property[ "json:column" ] )
						&& property[ "json:column" ] == mementoKey
					)
					||
					( property.name == mementoKey )
				)
				{
					// If the payload has a value then simply assign it to the property
					if
					(
						memento.keyExists( mementoKey )
						&&
						isArray( memento[ mementoKey ] ) == true
					)
					{
						// loop through the payload array for that property
						for ( var mementoItem in memento[ mementoKey ] ) {
							// instantiate the linked Bean
							bean = createObject( "component", property[ "json:cfc" ] ).init();
							// populate the Bean with the payload specific part
							bean.populate( mementoItem );
							// add the linked populated Bean to this Bean
							injectedBeans.append( bean );
						}
						_setProperty(
							property = property.name,
							value = injectedBeans
						);
					} else {
					// the payload value was a NULL
						_setPropertyAsNull( property = property.name );
					}
					variables.populatedProperties.append( property.name );
					break;
				}
			}
		}
	}


	/**
	 * @hint Serializes the simple properties of the Bean
	 */
	private struct function serializeSimpleProperties( required boolean everything ) {
		var out = createObject( "java", "java.util.LinkedHashMap").init();
		var properties = variables.categorizedProperties[ "simple" ];
		for ( var fieldName in properties ) {
			// exclude any fields that were not populated
			if ( everything == false && variables.populatedProperties.find( fieldName.name ) == 0 ) {
				continue;
			}
			// exclude any fields that are marked as non serializable
			if ( fieldName.keyExists( "json:serializable" ) && fieldName[ "json:serializable" ] == false ) {
				continue;
			}
			var field = fieldName.name;
			var fieldvalue = invoke( this, "get#fieldName.name#" );
			if ( isNull( fieldValue ) ) {
				out[ field ] = javacast( "null", 0 );
			} else {
				out[ field ] = fieldvalue;
				if ( fieldName.keyExists( "json:type" ) ) {
					switch ( fieldName[ "json:type" ] ) {
						case "string":
							out[ field ] = chr(2) & out[ field ];
						break;
						case "number":
							if ( isBoolean( out[ field ] ) ) {
								out[ field ] ? 1 : 0;
							} else {
								if ( out[ field ] == "" ) {
									out[ field ] = javacast( "null", 0 );
								} else {
									out[ field ] = out[ field ];
								}
							}
						break;
						case "date":
							if ( isDate( out[ field ] ) || isNumericDate( out[ field ] ) ) {
								out[ field ] = getIsoTimeString( out[ field ] );
							}
						break;
						case "boolean":
							if ( out[ field ] == "" ) {
								out[ field ] = javacast( "null", 0 );
							} else {
								out[ field ] = out[ field ] ? true : false;
							}
						break;
					}
				}
			}
		}
		return out;
	}


	/**
	 * @hint Serializes mapped one-to-one Bean properties
	 */
	private any function serializeOneToOneProperties( required boolean everything ) {
		var out = createObject( "java", "java.util.LinkedHashMap").init();
		var properties = variables.categorizedProperties[ "struct" ];
		// var properties = returnPropertiesByType( "struct" );
		for ( var property in properties ) {
			// exclude any fields that were not populated
			if ( everything == false && variables.populatedProperties.find( property.name ) == 0 ) {
				continue;
			}
			// exclude any fields that are marked as non serializable
			if ( property.keyExists( "json:serializable" ) && property[ "json:serializable" ] == false ) {
				continue;
			}
			if ( variables.keyExists( property.name ) ) {
				out[ property.name ] = variables[ property.name ].serialize( everything = everything );
			} else {
				out[ property.name ] = javacast( "null", 0 );
			}
		}
		return out;
	}


	private any function serializeOneToManyProperties( required boolean everything ) {
		var out = createObject( "java", "java.util.LinkedHashMap").init();
		var properties = variables.categorizedProperties[ "array" ];
		// var properties = returnPropertiesByType( "array" );
		for ( var property in properties ) {
			// exclude any fields that were not populated
			if ( everything == false && variables.populatedProperties.find( property.name ) == 0 ) {
				continue;
			}
			// exclude any fields that are marked as non serializable
			if ( property.keyExists( "json:serializable" ) && property[ "json:serializable" ] == false ) {
				continue;
			}
			if ( variables.keyExists( property.name ) ) {
				out[ property.name ] = [];
				for ( var propertyArray in variables[ property.name ] ) {
					out[ property.name ].append( propertyArray.serialize( everything = everything ) );
				}
			} else {
				out[ property.name ] = javacast( "null", 0 );
			}
		}
		return out;
	}


	/**
	 * @hint Removes all Character 2 fields, encoded or not, from the string.
	 * @jsonString The input string to delete the character from.
	 */
	private any function removeSTX( required any jsonString ){
		if ( isNull( jsonString ) ) {
			return jsonString;
		} else {
			var out = replace( jsonString, chr(2), "", "all" );
			out = replaceNoCase( out, "\u0002", "", "all" );
			return out;
		}
	}


	/**
	 * @hint Creates a STRUCT of the simple properties defintion with key names.
	 */
	private struct function returnNamedSimpleProperties() {
		var namedSimpleProperties = {};
		var simpleProperties = variables.categorizedProperties[ "simple" ];
		for ( var element in simpleProperties ) {
			namedSimpleProperties[ element.name ] = element;
		}
		return namedSimpleProperties;
	}


	/**
	 * @hint Returns all the properties of a category, like SIMPLE, ONE-TO-ONE and ONE-TO-MANY
	 * @type The category to filter the properties by
	 */
	private array function returnPropertiesByType( required string type ) {
		var propertiesByType = variables.categorizedProperties[ type ];
		var properties = [];
		for ( var property in propertiesByType ) {
			properties.append( property.name );
		}
		return properties;
	}


	/**
	 * @hint Changes the undelying Java type of a key value.
	 * @property The CFC property to set.
	 */
	private void function setKeyJavaType( required string property ) {
		var prop = variables.namedSimpleProperties[ property ];
		if ( prop.keyExists( "json:type" ) ) {
			var propValue = invoke( this, "get#property#" );
			_setProperty(
				property,
				javacast(
					getPropertyJavaCastType( prop["json:type"] ),
					propValue
				)
			);
		}
	}


	/**
	 * @hint Match the Java cast type based on the json:type property attribute.
	 * @type The property json:type attribute.
	 */
	private string function getPropertyJavaCastType( required string type ) {
		var javaType = "";
		switch ( type ) {
			case "boolean":
				javaType = "boolean";
			break;
			case "string": case "date":
				javaType = "string";
			break;
			case "number":
				javaType = "bigdecimal";
			break;
			default:
				javaType = "string";
			break;
		}
		return javaType;
	}


	/**
	 * @hint Returns the Bean properties categorized into SIMPLE, ONE-TO-ONE(struct) and ONE-TO-MANY(array) groups.
	 */
	private struct function returnCategorizedProperties() {
		// structure of the returned properties
		var categorizedProperties = {
			"simple" = [],
			"struct" = [],
			"array" = []
		};
		// get all properties regardless
		var properties = getMetaData( this ).properties;
		for ( var property in properties ) {
			if ( structKeyExists( property, "json:type" ) ) {
				switch ( property[ "json:type" ] ) {
					case "struct":
						categorizedProperties[ "struct" ].append( property );
					break;
					case "array":
						categorizedProperties[ "array" ].append( property );
					break;
					default:
						categorizedProperties[ "simple" ].append( property );
					break;
				}
			} else {
			/*
				Defaulting to not having to define the json:string
				for every property, but having it be the expected type
				if not defined.
			 */
				property[ "json:type" ] = "string";
				categorizedProperties[ "simple" ].append( property );
			}
		}
		return categorizedProperties;
	}


	/**
	 * @hint Uses underlying Java functionality to change a QUERY into a STRUCT
	 * @memento The query data to transform
	 */
	private struct function queryToStruct( required query memento ) {
		var data = {};
		// get array of query columns in the proper case as defined in the SELECT query
		// var queryColumns = memento.getMetaData().getColumnLabels();
		var queryColumns = getMetadata( memento ).map(
			function( col ) {
				return col.name;
			}
		);
		// loop through the query and construct valid data and nulls
		for ( var column in queryColumns ) {
			// java hooks for determining if a column is really a NULL
			if ( isQueryColumnNull( qry=memento, column=column ) ) {
				data[ column ] = javacast( "null", 0 );
			} else {
				data[ column ] = memento[ column ][ 1 ];
			}
		}
		return data;
	}


	/**
	 * @hint Java underlying checks for a query NULL value in a column
	 * @qry The query to check against
	 * @column The column name in the query
	 * @row The row to check against
	 */
	private any function IsQueryColumnNull(
		required query qry,
		required string column,
		numeric row = 1
	){
		var cacheRow = qry.currentRow;
		qry.absolute( row );
		var value = qry.getObject( column );
		var valueIsNull = qry.wasNull();
		qry.absolute( cacheRow );
		return valueIsNull;
	}


	/**
	 * Function by Richard Herbert
	 * @hint Formats a date into the ISO-8601 format
	 * @datetime The date and time to convert
	 * @convertToTUC Whether to use the UTC time zone or not
	 */
	private string function getIsoTimeString(
		string datetime = "",
		boolean convertToUTC = true
	){
		if ( len(dateTime ) ) {
			if ( convertToUTC == true ) {
				// Convert only if it's not already in UTC.
				if ( find("T", datetime) && find("Z", datetime) ) {
					return datetime;
				} else {
					datetime = dateConvert( "local2utc", datetime );
				}
			}
			/*
				When formatting the time, make sure to use "HH" so that the
				time is formatted using 24-hour time.
			 */
			return
				dateFormat( datetime, "yyyy-mm-dd" ) &
				"T" &
				timeFormat( datetime, "HH:mm:ss" ) &
				"Z";
		} else {
			return javacast( "null", 0 );
		}
	}


	/**
	 * @hint Internal evaluator for setting a property value
	 * @property The property to set
	 * @value The value to set the property to
	 * @cfc The object that the property is in
	 */
	private any function _setProperty(
		required string property,
		required any value,
		any cfc = this
	){
		var args[ property ] = value;
		invoke( cfc, "set#property#", args );
	}


	/**
	 * @hint Internal evaluator for setting a property value as NULL
	 * @property The property to set
	 * @cfc The object that the property is in
	 */
	private any function _setPropertyAsNull(
		required string property,
		any cfc = this
	){
		evaluate( "cfc.set#property#( javacast('null', 0) )" );
	}


}