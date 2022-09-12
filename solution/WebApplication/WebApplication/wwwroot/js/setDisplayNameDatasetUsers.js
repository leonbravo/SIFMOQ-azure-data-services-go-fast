
function setDisplayName(_this) {

    var numbers = _this.name.match(/\d+/g).map(Number);

    // get the index from the name attribute of selector
    const index = numbers[0];

    if (index !== null) {
        const dNameFieldId = (`DataStewards_${index}__DisplayName`);

        // get the display name of the selected object
        const dName = $(_this).find(":selected").text();

        $(`#${dNameFieldId}`)[0].value = dName;
    }
}

function setOwnerDisplayName(_this) {

    let dNameField = "";
    const dName = $(_this).find(":selected").text();

    if (_this.name.startsWith("DataOwner")) {
        dNameField = $("#ownerName")[0];
    } else if (_this.name.startsWith("DataCustodian")) {
        dNameField = $("#custodianName")[0];
    }

    dNameField.value = dName;
}