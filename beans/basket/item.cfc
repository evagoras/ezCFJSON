component accessors=true extends="beans.base" {


	property name="id"						json:type="number";
	property name="size"					json:type="number";
	property name="quantity"				json:type="number";
	property name="unit";
	property name="productCode";
	property name="description";
	property name="unitCost"				json:type="number";
	property name="totalUnitsCost"			json:type="number";
	property name="totalUnitsDiscount"		json:type="number";
	property name="status";
	property name="purchaseOrderNumber";


	function init(){
		super.init();
		return this;
	}


}