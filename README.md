# ezCFJSON
A base component for **safely** (de)serializing from/to JSON and native CF objects.

## How to use
1. create a CFC that extends the base, found under `/beans/base.cfc`
1. add 3 types of properties: `simple`, `struct`s or `array`s
```
component extends="beans.base" accessors=true {

	property name="ID" json:type="number";
	property name="title" json:serializable=false;
	property name="firstName" json:column="strFirstName";
	property name="familyName";
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

## json:column
The data which is used to populate the Bean may have a different key name going in than what you need coming out. For example, your JSON may need to respond with `firstName`, while your query column populating the Bean is called `strFirstName`. You would then create a property like this:
```
property name="firstName" json:column="strFirstName";
```

## json:type
The default is `string`. It correctly serializes and deserializes into the correct Java types based on the attribute you assign.

Name | JavaCast | Examples
:--- | :--- | :--- 
`string` | `string ` | "example", "no", "true", "12345"
`boolean` | `boolean` | true, false, 1, 0, yes, no, "yes, "no", "1", "0", "true", "false"
`number` | `bigdecimal` | 3.1415, "3.1215", 3, 3.1
`date` | `string` | "2017-04-26T10:36:00Z"
`array` | CFC one-to-many | [], [{}, {}]
`struct` | CFC one-to-one | {}


## json:serializable
`true` or `false`. The default is `true`.<br>
This is a boolean flag to indicate whether to output the key or not.

## json:cfc
The CFC location of the Bean to map as either a one-to-one (`struct`) or one-to-many (`array`).
