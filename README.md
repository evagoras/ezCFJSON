# ezCFJSON
A base component for **safely** (de)serializing from/to JSON and native CF objects.

## Summary
This base component goes around the legendary CFML (de)serialization issues because of the fact that it's a typeless language and the decisions that were taken in its design regarding NULLs. It will correctly handle value database NULLs, struct NULLs, JSON NULLs, and keep original strings of values like booleans or numerics. It will also let you define in one place the casing of the resulting JSON file (in the CFC), letting you use normal struct notation in your code instead of worrying about wrapping your name in quotes to get your key named right. It will automatically wire up relationships between other beans in a one-to-one (struct) or one-to-many (array) way.

## How to create a new Bean
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
The CFC location of the Bean to map as either a one-to-one (`struct`) or one-to-many (`array`). This attribute needs to be defined in conjuction with `json:type` to define the type of relationship to create:
* `struct`: one-to-one
* `array`: one-to-many
