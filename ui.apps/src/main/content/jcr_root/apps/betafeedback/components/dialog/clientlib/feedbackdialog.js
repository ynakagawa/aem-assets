/*
 *
 * ADOBE CONFIDENTIAL
 * __________________
 *
 *  Copyright 2015 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 */

jQuery(function ($) {

    // TODO use HTML5 FromData for modern browsers
    // TODO validate email address

    var dialog = $("#feedback-dialog")[0];
    dialog.on('coral-overlay:open', function () {
        // focus() works only if the dialog is visible
        setTimeout(function () {
            $("coral-dialog-content :enabled:not([readonly]):first", dialog).focus();
        }, 100);
    });
    dialog.on('coral-overlay:close', function () {
        window.close();
    });
    dialog.show();

    var $form = $('form', dialog);
    var $messages = $(".messages", $form);

    $form.on("submit", function (e) {
        e.preventDefault();
        $messages.empty();

        var $editableFields = $("coral-dialog-content :input:not(button):visible:enabled:not([readonly])", $form),
            $requiredFields = $editableFields.not(":file");
        var $blankFields = $requiredFields.filter(function() {
            return !$.trim($(this).val());
        });

        if ($blankFields.length > 0) {
            addAlert('error', Granite.I18n.get("Please complete the feedback form."));
            $blankFields.addClass("is-invalid").first().focus();
        } else {
            var $inputs = $(":input:enabled:not(:file)", $form); // Files will be ignored by iframe-transport if disabled

            function handleResponse(data) {
              var success = true;
              if (data.message) {
                  success = data.message.type !== "error";
                  addAlert(data.message.type, data.message.content);
              }
              if (success) {
                  window.setTimeout(function() {
                    dialog.hide();
                  }, 2000);
              }
            }

            $.ajax({
                url:$form.attr("action"),
                type:"post",
                dataType: "iframe json",
                fileInput: $(":file:enabled"),
                formData: $inputs.serializeArray(),
                beforeSend: function () {
                    $inputs.prop("disabled", true);
                    if (window.localStorage) {
                        localStorage.setItem("feedback.name", $("[name='name']", $form).val());
                        localStorage.setItem("feedback.email", $("[name='email']", $form).val());
                        localStorage.setItem("feedback.customer", $("[name='customer']", $form).val());
                    }
                },
                success: handleResponse,
                error: function (xhr) {
                    try {
                        handleResponse(JSON.parse(xhr.responseText));
                    } catch (e) {
                        $('<div class="coral-Alert coral-Alert--error"><i class="coral-Alert-typeIcon coral-Icon coral-Icon--sizeS coral-Icon--alert"></i><div class="coral-Alert-message">' + Granite.I18n.get("There was an error with your request.") + '</div></div>').appendTo($messages);
                    }
                },
                complete: function () {
                    $inputs.prop("disabled", false);
                }
            });
        }
    })
        .on("focus", ":input:not([readonly])", function () {
            $(this).removeClass("is-invalid");
        })
        .on("blur", ":input:not([readonly])", function () {
            $(this).toggleClass("is-invalid", !$.trim($(this).val()));
        });

    if (window.localStorage) {
        $("[name='name']:enabled", $form).val(localStorage.getItem("feedback.name"));
        $("[name='email']:enabled", $form).val(localStorage.getItem("feedback.email"));
        $("[name='customer']:enabled", $form).val(localStorage.getItem("feedback.customer"));
    }

    function addAlert(variant, message) {
        var alert = new Coral.Alert();
        alert.variant = variant;
        alert.content.innerText = message;
        $messages.append(alert);
    }

});