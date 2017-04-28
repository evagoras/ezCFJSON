# ezCFJSON
A base component for (de)serializing from/to JSON and native CF objects

## How to use
1. create a CFC that extends this base
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

## Property examples:
```
property name="firstName" json:type="string" json:column="FNAME" json:serializable=false;
property name="shippingAddress" json:type="struct" json:cfc="beans.basket.address";
property name="items" json:type="array" json:cfc="beans.basket.item";
```

## json:type
1. `string`   "example"
1. `boolean`  true/false
1. `number`   3.1415
1. `date`     "2017-04-26T10:36:00Z"
1. `struct`   {}
1. `array`    []

## json:serializable
true/false
This is a boolean flag to indicate whether to output the key or not

## json:cfc
The CFC location of the Bean to map as either a one-to-one(struct) or one-to-many(array)
