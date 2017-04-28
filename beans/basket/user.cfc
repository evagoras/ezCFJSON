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