$.validator.addMethod('must-be-true', function (value, element, params) {
    return element.checked;
});

$.validator.unobtrusive.adapters.add('must-be-true', [], function (options) {
    options.rules['must-be-true'] = {};
    options.messages['must-be-true'] = options.message;
});