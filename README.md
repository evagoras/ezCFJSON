# ezCFJSON

## Summary
A base component for **safely** (de)serializing from/to JSON and native CF objects.

A single file which is independent of any framework and works with Lucee 4.5+ or Adobe 11+. Define your JSON response using CFCs, extending this base and off you go.

## Features
* ACF11+ & Lucee4.5+ compatible
* Handles NULLs (database, structs, JSON files)
* Maintains strings (booleans, numerics)
* Enforces key casing
* Auto-wires one-to-one and one-to-many relationships with other CFCs
* Populates from CF Struct, CF Query or JSON string
* Outputs ISO-8601 date format
* Serializes either all Bean fields or just the populated ones

## How to create a new Bean
1. create a CFC that extends the base, found under `/beans/base.cfc`
1. add 3 types of properties: `simple`, `struct`s or `array`s
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

Example
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
<img src="https://github.com/evagoras/ezCFJSON/blob/master/populated_bean.png" alt="Populated Bean" width="300">

## toJson([everything=true])
Serializes the Bean (and its nested relationships) to a JSON string
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
user.toJson();
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
user.toNative();
```

## Property json: attributes

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

### json:cfc & json:type="array/struct"
The `json:cfc` is a Bean to map internally to create a nested relationship with either one or many of them. This attribute needs to be defined in conjuction with `json:type` to define the type of relationship to create:
* `struct`: one-to-one
* `array`: one-to-many
