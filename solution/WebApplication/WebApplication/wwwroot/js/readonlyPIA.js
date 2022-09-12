$(document).ready(function () {

    $('.editBtn').hide();

    // disable summary steps which are exclusive to private data sets
    if ($('#privacyStatusValue')[0].textContent.trim() == "Public") {
        $(".privateSectionSummary").hide();
    }

    $('#PIASUmmaryPrintBtn').on('click',
        function() {
            window.print();
        });
});