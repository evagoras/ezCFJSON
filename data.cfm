<cfscript>
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

json = '{
    "ID": 233,
    "firstName": "Evagoras",
    "familyName": "Charalambous",
    "distributorID": 12345,
    "active": true,
    "billingAddress": {
        "username": null,
        "attention": null,
        "organisation": "my company",
        "address1": "Street 1",
        "address2": null,
        "city": null,
        "county": null,
        "country2LCode": null,
        "postcode": null,
        "email": null,
        "telephone": "12345"
    },
    "shippingAddress": {
        "username": null,
        "attention": null,
        "organisation": null,
        "address1": null,
        "address2": "Street 2",
        "city": "London",
        "county": null,
        "country2LCode": null,
        "postcode": null,
        "email": null,
        "telephone": null
    },
    "items": [
        {
            "id": 1,
            "size": null,
            "quantity": 3,
            "unit": null,
            "productCode": null,
            "description": null,
            "unitCost": 4.56,
            "totalUnitsCost": null,
            "totalUnitsDiscount": null,
            "status": null,
            "purchaseOrderNumber": null
        },
        {
            "id": 2,
            "size": 4,
            "quantity": null,
            "unit": null,
            "productCode": null,
            "description": null,
            "unitCost": 10.00,
            "totalUnitsCost": null,
            "totalUnitsDiscount": null,
            "status": null,
            "purchaseOrderNumber": null
        }
    ]
}';
</cfscript>