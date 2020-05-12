//= require jquery
//= require jquery_ujs
//= require cfa_styleguide_main

var toggleDisabledField = (function() {
    var f = {
        init: function() {
            var $checkbox = $('.checkbox-with-associated-field-to-disable input'),
                $fieldToDisable = $('.associated-field-to-disable');

            toggle = function($checkbox, $fieldToDisable) {
                $fieldToDisable.find('input').prop('disabled', $checkbox.is(':checked'));
                $fieldToDisable.toggleClass('disabled', $checkbox.is(':checked') );
            };

            toggle($checkbox, $fieldToDisable);

            $checkbox.change(function (e) {
                toggle($checkbox, $fieldToDisable);
            });
        }
    };
    return {
        init: f.init
    }
})();

$(document).ready(function() {
    toggleDisabledField.init();
});