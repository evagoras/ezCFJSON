# ezCFJSON
A base component for **safely** (de)serializing from/to JSON and native CF objects.

## Summary
A single file which is independent of any framework and works with Lucee 4.5+ or Adobe 11+. This can be used for any new project, to define your JSON response using CFCs, by extending this base, and off you go.

## Features
* ACF11+ & Lucee4.5+ compatible
* Properly handles NULLs (from database, structs, or JSON files)
* Maintains strings as string (e.g. "yes", "no", "123", etc.)
* Enforces key casing (e.g. "firstName")
* Auto-wires one-to-one and one-to-many relationships with other CFCs
* Populates from CF Struct, CF Query or JSON string
* Outputs ISO-8601 date format
* Serializes all Bean fields or just the populated ones
* Can exclude individual keys from being serialized
* A key can have different population/serialization names

## How to create a new Bean
1. Your new CFC needs to extend the base, found under this project at `/beans/base.cfc`.
1. Your `init` function needs to `super.init()` the base.
1. Your CFC needs to have `accessors` enabled so that getters and setters are automatically created for your properties.
1. Use a template similar to the one below for creating properties.
```
component extends="beans.base" accessors=true {

	property name="ID" json:type="number";
	property name="title" json:serializable=false;
	property name="firstName" json:column="strFirstName";
	property name="familyName";
	property name="dateOfBirth" json:type="date";
	property name="distributorID" json:type="number";
	property name="active" json:type="boolean";
	property name="billingAddress" json:type="struct" json:cfc="beans.basket.address";
	property name="shippingAddress" json:type="struct" json:cfc="beans.basket.address";
	property name="items" json:type="array" json:cfc="beans.basket.item";

	function init() {
		super.init();
		return this;
	}

}
```

## Public methods

### Populate()
You can populate from
* a CF Struct
* a CF Query
* a JSON string

This example populates from a CF struct:
```
struct = {
	id = 233,
	title = "Dr",
	strfirstname = "Evagoras",
	familyname = "Charalambous",
	distributorid = 12345,
	active = true,
	billingAddress = {
		organisation = "my company",
		address1 = "Street 1",
		telephone = "12345"
	},
	shippingAddress = {
		address2 = "Street 2",
		"city" = "London"
	},
	items = [
		{
			id = 1,
			quantity = 3,
			unitcost = 4.56
		},
		{
			id = 2,
			size = 4,
			unitcost = 10.00
		}
	]
};
user = new user();
user.populate( struct );
```
<img src="https://github.com/evagoras/ezCFJSON/blob/master/populated_bean.png" alt="Populated Bean" width="400">

## toJson([everything=true])
Serializes the Bean (and its nested relationships) to a JSON string.

This example populates and serializes from a JSON string:
```
jsonString = '{
	"billingAddress": {
		"telephone": "12345",
		"organisation": "my company",
		"address1": "Street 1"
	},
	"shippingAddress": {
		"address2": "Street 2",
		"city": "London"
	},
	"distributorID": 12345,
	"items": [
		{
			"id": 1,
			"quantity": 3,
			"unitCost": 4.56
		},
		{
			"size": 4,
			"id": 2,
			"unitCost": 10.00
		}
	],
	"ID": 233,
	"firstName": "Evagoras",
	"active": true,
	"familyName": "Charalambous"
}';
user = new user();
user.populate( jsonString );
user.toJson( everything = false );
```
Notice that we asked to have only the populated fields serialized. This is the result:
```
{"ID":233,"firstName":"Evagoras","familyName":"Charalambous","distributorID":12345,"active":true,"billingAddress":{"organisation":"my company","address1":"Street 1","telephone":"12345"},"shippingAddress":{"address2":"Street 2","city":"London"},"items":[{"id":1,"quantity":3,"unitCost":4.56},{"id":2,"size":4,"unitCost":10.0}]}
```

### toNative([everything=true])
Returns a CF Struct of the Bean and its nested relatiosnhips
```
struct = {
	id = 233,
	title = "Dr",
	strfirstname = "Evagoras",
	familyname = "Charalambous",
	distributorid = 12345,
	active = true,
	billingAddress = {
		organisation = "my company",
		address1 = "Street 1",
		telephone = "12345"
	},
	shippingAddress = {
		address2 = "Street 2",
		"city" = "London"
	},
	items = [
		{
			id = 1,
			quantity = 3,
			unitcost = 4.56
		},
		{
			id = 2,
			size = 4,
			unitcost = 10.00
		}
	]
};
user = new user();
user.populate( struct );
user.toNative( everything = false );
```
We asked to serialize just the populated fields, so here's a screenshot of the resulting struct:

<img src="https://github.com/evagoras/ezCFJSON/blob/master/toNative.png" alt="toNative() result" width="400">

## Property attributes

### json:column
The data which is used to populate the Bean may have a different key name going in than what you need coming out. For example, your JSON may need to respond with `firstName`, while your query column populating the Bean is called `strFirstName`. You would then create a property like this:
```
property name="firstName" json:column="strFirstName";
```
In other words, for this case, the `column` is what goes into the Bean, the `name` is what comes out.

### json:type
The default is `string`. It correctly serializes and deserializes into the correct Java types based on the attribute you assign.

Name | JavaCast | Examples
:--- | :--- | :--- 
`string` | `string ` | "example", "no", "true", "12345"
`boolean` | `boolean` | true, false, 1, 0, yes, no, "yes, "no", "1", "0", "true", "false"
`number` | `bigdecimal` | 3.1415, "3.1215", 3, 3.1
`date` | `string` | "2017-04-26T10:36:00Z"
`array` | CFC one-to-many | [], [{}, {}]
`struct` | CFC one-to-one | {}


### json:serializable
`true` or `false`. The default is `true`.<br>
This is a boolean flag to indicate whether to output the key or not.

### json:cfc
The `json:cfc` is a Bean to map internally to create a nested relationship with either one or many of them. This attribute needs to be defined in conjuction with `json:type` to define the type of relationship to create:
* `struct`: one-to-one
* `array`: one-to-many
