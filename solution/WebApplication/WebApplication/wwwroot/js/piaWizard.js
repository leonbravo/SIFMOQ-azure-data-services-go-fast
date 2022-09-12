
var globalModelData;

function getPIAWizardModelData(userObj) {
    globalModelData = userObj;
}

var piaDatePicker = document.getElementById("piaDatePicker");
var dateNow = moment().format("YYYY-MM-DD");

piaDatePicker.max = dateNow;

$(document).ready(function () {

    // SmartWizard initialize
    $('#smartwizard').smartWizard({
        theme: 'dots',
        autoAdjustHeight: true, 
        justified: true, 
        toolbarSettings: {
            toolbarPosition: 'both', // none, top, bottom, both
            showNextButton: false,
            toolbarExtraButtons: [
                // Save & Next Button
                // Used to progress to the next page while also posting form
                $('<button></button>').text('Save & Next')
                    .addClass('btn btn-info')
                    .attr('id', 'saveNext')
                    .on('click', function () {
                        submit(1);
                    }),

                // Save Button
                // Used to save the current page without moving
                $('<button></button>').text('Save')
                    .addClass('btn btn-info')
                    .attr('id', 'piaSave')
                    .on('click', function () {
                        submit(0);
                    }),
            ]
        },
        keyboardSettings: {
            keyNavigation: false, // set this to true for seamless dev exp
        }
    });

    $('#smartwizard').smartWizard("reset");

    $("#smartwizard").on("stepContent", function (e, anchorObject, stepIndex, stepDirection) {
        if (stepIndex === 8) {
            $("#saveNext").prop("disabled", true);
            $("#piaSave").prop("disabled", true);
            $(".toolbar-bottom").hide();
        } else {
            $("#saveNext").prop("disabled", false);
            $("#piaSave").prop("disabled", false);
            $(".toolbar-bottom").show();
            initValidatorStep(stepIndex); // todo: this could be better implemented
        }
    });

    $('#submitBtn').on('click', function () {
        submit(1);
    });

    window.onbeforeunload = setOnBeforeUnload;

    function setOnBeforeUnload() {
        return "Leaving this page will reset the data in the wizard";
    };


    function submit(submissionMode) {
        window.onbeforeunload = null;
        // Set Step Value before submitting - so we know which page to move on from
        $("#Step").val($('#smartwizard').smartWizard("getStepIndex"));
        // Set submission method to next so we move after submitting
        $("#SubmissionMethod").val(submissionMode);
        // Post form - will refresh the page to the same step
        $("#smartwizard > form").submit();
    }

    // If current step is greater than the max step
    // This will happen after using the save & next button
    if (globalModelData.step > globalModelData.maxStep) {
        // Update max step
        $("#MaxStep").val(globalModelData.step);
    }

    // Iterate over steps we've seen and set them to active
    // If we don't do this then all steps but 1 will be disabled
    for (let i = 0; i < eval($("#MaxStep").val()); i++) {
        $('#smartwizard').smartWizard("goToStep", i);
    }

    // Initialize the leaveStep event
    $("#smartwizard").on("leaveStep", function (e, anchorObject, currentStepIndex, nextStepIndex, stepDirection) {
        // When going forward
        if (stepDirection == "forward") {
            // If moving to a page we've never seen before
            if (nextStepIndex + 1 > $("#MaxStep").val()) {
                // Update the max step counter
                $("#MaxStep").val(nextStepIndex + 1);
            }
        }
    });

    $('#addSteward').click(function () {
        window.onbeforeunload = null;
        $.ajax({
            async: true,
            data: $('#form').serialize(),
            type: "POST",
            url: "/Wizards/AddDataSteward",
            success: function (partialView) {
                $('#stewardsContainer').html(partialView);
                window.onbeforeunload = setOnBeforeUnload;
            }
        });
    });

    $('#removeSteward').click(function () {
        window.onbeforeunload = null;
        $.ajax({
            async: true,
            data: $('#form').serialize(),
            type: "POST",
            url: "/Wizards/RemoveDataSteward",
            success: function (partialView) {
                $('#stewardsContainer').html(partialView);
                window.onbeforeunload = setOnBeforeUnload;
            }
        });
    });

    // After initialization jump to the step we want (on refresh, start at the beginning)
    $('#smartwizard').smartWizard("goToStep",
        Math.max(0, Math.min(globalModelData.step, $("#smartwizard > ul")[0].children.length - 1)));

    $("#smartwizard").on("stepContent",
        function (e, anchorObject, stepIndex, stepDirection) {
            var requestedStep = "PIAStep" + (stepIndex + 1);
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
    
    // if maxstep is 0/start then display modal
    var maxStepVal = $("#MaxStep")[0].value;
    if (maxStepVal == 0) {
        $('#PIAProcessModal').modal('show');
    }

    // enable other option input if clicked
    var otherOption = $("#ImpactManagementReductionOptions_Options_4__IsSelected")[0];
    var option = $("#ImpactManagementOtherOption");

    if (otherOption.checked === false) {
        option.prop("readonly", true);
    }

    otherOption.addEventListener("change", function () {
        if (this.checked) {
            option.prop("readonly", false);
        } else {
            option.val("");
            option.prop("readonly", true);
        }
    });

    // enable suppression questions if clicked
    var deIdentifiedDataBox = $(":radio[value=deidentified]")[0];
    var personalDataBox = $(":radio[value=personal]")[0];

    deIdentifiedDataBox.addEventListener("change", function () {
        $("#suppressionRuleQuestions").each(function () {
            var input = $(this).find(':input');

            input.prop("disabled", false);
        });
    });

    personalDataBox.addEventListener("change", function () {
        $("#suppressionRuleQuestions").each(function () {
            var input = $(this).find(':input').val("");

            input.prop("checked", false);
            input.prop("disabled", true);
        });
    });

    if (personalDataBox.checked) {
        // Create a new 'change' event and dispatch it
        var event = new Event('change');
        personalDataBox.dispatchEvent(event);
    }
    
    var tgSelection = document.getElementById("tgSelection");
    var dsSelection = document.getElementById("dsSelection");

    function insertText(event) {
        var source = event.target || event.srcElement;

        var dropdownText = source.options[source.selectedIndex].text;

        if (dropdownText === "Select Your Source System" || dropdownText === "Select Your Site Zone") {
            return;
        }

        if (source.id === "dsSelection") {
            var datasetField = document.getElementById("spvSiteName");
            var siteNameField = document.getElementById("hiddenSiteName");

            datasetField.value = dropdownText; // set the hidden field to make form save properly
            siteNameField.value = dropdownText;
        } else {
            var taskGroupField = document.getElementById("spdSourceSystemName");
            taskGroupField.value = dropdownText;
        }
    }

    tgSelection.addEventListener("change", insertText);
    dsSelection.addEventListener("change", insertText);
    

    function incrementMaxStepIfZero() {
        var maxStepVal = $("#MaxStep")[0].value;

        var newStepVal = maxStepVal == 0 ? 1 : maxStepVal;

        $("#MaxStep")[0].value = newStepVal;
    }

    function TogglePrivateDataSetStepsActive(privacyStatus) {
        if (privacyStatus == "Public") {
            disablePrivateSteps();
        } else {
            $('#privacyStatus').val("Private");
            $('.privateDataSetWarning').hide();
            $(".privateSectionSummary").show();
            $('.privateDataSetStep :input').show();
        }
    }

    // ON LOAD - disable summary steps/questions which are exclusive to private data sets
    var privacyStatus = $("#DataSetPrivacyStatus option:selected").text();
    
    if (privacyStatus == "Public") {
        disablePrivateSteps();
    }

    function disablePrivateSteps() {
        $('.privateDataSetWarning').show();
        $(".privateSectionSummary").hide();
    }

    var privacyDropDown = document.getElementById("DataSetPrivacyStatus");
    function showSkipButton() {
        $('.privateDataSetWarning').show();
        $('.skipToSummary').show();
    }
    privacyDropDown.onchange = showSkipButton;

    var privacyStatusIcon = document.getElementById("privacyModalBtn");
    function showPIAModal() {
        $('#PIAProcessModal').modal('show');
    }
    privacyStatusIcon.onclick = showPIAModal;

    function initValidatorStep(stepIndex) {
        var stepNumber = `#step-${ ++stepIndex }`;

        initValidator(stepNumber);
    }
    
    function initValidator(element) {
        var validator = $(element).validate();

        $(element).find("input[type=text], input[type=date], :radio, textarea, select").on("change", function () {
            _validate(element, validator);
        });
    }
    function _validate(element, validator) {
        var invalidCount = 0;

        $(element).find("input[type=text], input[type=date], :radio, textarea, select").not(":hidden").each(function () {
            var x = !validator.check(this);
            if (x)
                invalidCount++;
        });

        return invalidCount === 0;
    }
});