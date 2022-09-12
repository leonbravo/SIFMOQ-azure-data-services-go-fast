var options = {
    mode: 'code'
};

var container = document.getElementById("jsoneditor");
var editor = new JSONEditor(container, options);

function setJSON() {
    var json = editor.get();
    var input = document.getElementById("jsonInput");
    input.value = json;

}

$('#tmSubmit').on('click', function () {
    event.preventDefault();
    mapJsonInputToForm();
});

function mapJsonInputToForm() {
    var json = JSON.stringify(editor.get());

    $('#jsonInput')[0].value = json;


    $('#tmForm').submit();
}