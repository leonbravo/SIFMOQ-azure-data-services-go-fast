function()
{
    local tout = import "../output/tout.json",
	"name": tout.datafactory_name,
	"location": "australiaeast",
	"identity": {
		"type": "SystemAssigned",
		"principalId": "03d33550-0c51-4fdf-a0e3-d1393dc3bbc0",
		"tenantId": tout.tenant_id
	}
}