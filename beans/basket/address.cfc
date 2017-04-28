component accessors=true extends="beans.base" {


	property name="username";
	property name="attention";
	property name="organisation";
	property name="address1";
	property name="address2";
	property name="city";
	property name="county";
	property name="country2LCode";
	property name="postcode";
	property name="email";
	property name="telephone";


	function init() {
		super.init();
		return this;
	}


}