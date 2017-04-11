/*
 *
 * ADOBE CONFIDENTIAL
 * __________________
 *
 *  Copyright 2013 Adobe Systems Incorporated
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

    $(document).on('click', '.endor-Button--feedback', function (event) {
        var $button = $(event.currentTarget);
        var data = $.extend({}, $button.data(), {url:location.href});
        var feedbackBaseUrl = data.href,
            feedbackUrl = feedbackBaseUrl;
        delete data.href;
        feedbackUrl += "?" + $.param(data, true);

        var width = 500, height = 580,
            left = (screen.width / 2) - (width / 2),
            top = (screen.height / 2) - (height / 2);

        var popup = window.open(feedbackUrl, 'feedback', 'height=' + height + ',width=' + width + ', top=' + top + ', left=' + left);
        if (popup) {
            popup.focus();
            $(window).on('unload', function () {
                popup.close();
            });
        }

        function checkAvailable(repeat) {
            $.ajax({
                dataType: 'jsonp',
                url: feedbackBaseUrl,
                error: function (xhr, textStatus) {
                    if (repeat && textStatus !== 'timeout') {
                        // Try again because session might have been expired
                        checkAvailable(false);
                    } else {
                        popup && popup.close();
                        window.setTimeout(function () {
                            var contact = 'AEMBeta@adobe.com',
                                msg = Granite.I18n.get('The beta feedback service is not available at the moment. If you believe this is an error, please contact the AEM Beta Team ({0}).', [contact]);
                            window.alert(msg);
                        }, 0);
                    }
                },
                timeout: 3000
            });
        }

        // Check if feedback service is available
        var isLocal = (feedbackUrl[0] == '/' || feedbackUrl.indexOf('//' + location.host + '/') != -1);
        if (!isLocal) {
            checkAvailable(true);
        }
    });

});

