$(document).ready(function () {

    // SmartWizard initialize
    $('#smartwizard').smartWizard({
            theme: 'dots',
            keyboardSettings: {
                keyNavigation: false // set this to true for seamless dev exp
            }
        }
    );

    $('#smartwizard').smartWizard("reset");

    


    // display preview of task group details
    $('#efnTgSelector').change(function () {
        var optionSelected = $("option:selected", this);
        var valueSelected = this.value;


        $.ajax({
            async: true,
            type: "GET",
            url: "/TaskGroup/GetTaskGroupDetails/" + valueSelected,
            success: function (partialView) {
                $('#taskGroupDetails').html(partialView);
            }
        });
    });

    $("#smartwizard").on("stepContent",
        function (e, anchorObject, stepIndex, stepDirection) {
            var requestedStep = "EFNStep" + (stepIndex + 1);
            var converter = new showdown.Converter();

            $.ajax({
                async: true,
                data: { fileName: requestedStep },
                type: "GET",
                url: "/Help/GetHelp/",
                success: function (content) {
                    content = converter.makeHtml(content);
                    $('#helpContent').html(content);
                },
                error: function () {
                    var error = "Content was not found.";
                    $('#helpContent').html(error);
                }
            });
        });
});