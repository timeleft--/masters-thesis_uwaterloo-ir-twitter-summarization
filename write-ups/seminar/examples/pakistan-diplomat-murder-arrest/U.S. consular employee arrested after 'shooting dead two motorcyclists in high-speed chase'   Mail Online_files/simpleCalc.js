/* <![CDATA[ */
(function()
{
    jQuery(document).ready(
        function() {

            jQuery('#simpleEstForm').bind('submit', function() {
                var isCalculateSubmit = jQuery("#divCalculator").is(":visible");
                if (MY_FRI.validatePostcode() && isCalculateSubmit) {
                    jQuery("#divCalculator").hide();
                    FRI.getTopTariff();
                    jQuery("#friCalculator form").attr("target", "_blank");
                    return FRI.canContinue;
                }
                return false || !isCalculateSubmit;
            });
        });


    jQuery(document).ready(
        function() {
            var postCodeLength = jQuery.trim(jQuery("#postcode").attr("value")).length;
            if (postCodeLength > 0) {
                jQuery("#friCalculator #calculate").focus();
            }
            FRI.openLinksInNewWindow();
        });

    var FRI = {
        openLinksInNewWindow: function() {
            jQuery("#friCalculator a").attr("target", "_blank");
        },
        canContinue: false,
        getTopTariff: function() {
            try {
                var postCode = jQuery("#PostCode").attr("value");
                var usage;
                if (jQuery("#usage_low").attr("checked")) {
                    usage = 'low';
                }
                else if (jQuery("#usage_high").attr("checked")) {
                    usage = 'high';
                }
                else {
                    usage = 'medium';
                }
                jQuery.getJSON("http://www.energyhelpline.com/api/calculator/simpleestimator?version=1.1&apikey=8DC06678-4A44-365C-91FF-930754689A77&SimpleUsage=" + usage + "&callback=?&postcode=" + postCode,
                    function(data) {
                        jQuery("#result").empty();

                        var result;
                        if (typeof data.Errors !== "undefined" || data.BestDualFuelSupplierTariffName == null) {
                            result = "<div id='unableToGetQuickDeal'><p>We weren't able to find your cheapest deal using our quick calculator.</p><p>Click continue to visit our energy homepage for a fuller comparison.</p></div>";
                            jQuery("#simpleEstForm").append(result);
                            jQuery("#simpleEstForm").append(jQuery("<input />").attr("type", 'submit').attr('title', 'Continue to find the best deal based on your current energy supply and usage').attr("value", 'Continue').attr('id', 'continue'));
                            FRI.canContinue = true;
                        }
                        else {
                            result = "<h3>We expect your cheapest deal to be:</h3>";
                            result += "<p class='tariffName'>" + data.BestDualFuelSupplierTariffName;
                            result += "<img src='http://www.energyhelpline.com/Uploads/SupplierLogos/" + data.BestDualFuelSupplierLogo + "' title ='" + data.BestDualFuelSupplierTariffName + "' alt='" + data.BestDualFuelSupplierTariffName + "' class ='tariffLogo' /></p>";
                            result += "<p id='savings'>This could save you: <span>&pound;";
                            result += parseInt(data.DefaultElectricityCost, 10) + parseInt(data.DefaultGasCost, 10) - parseInt(data.BestGasTariffCost, 10) - parseInt(data.BestElecTariffCost, 10);
                            result += "</span></p>";

                            jQuery("#simpleEstForm").append(result);
                            jQuery("#simpleEstForm").append(jQuery("<input />").attr("type", 'submit').attr('title', 'Continue to find the best deal based on your current energy supply and usage').attr("value", 'Continue').attr('id', 'continue'));
                            FRI.canContinue = true;
                        }
                        jQuery("#friCalculator #continue").focus();
                    });
            }
            catch(e) {
                alert('Error in getting top tariff data: ' + e);
            }
        }
    };

    var MY_FRI = {
        validatePostcode: function() {

            try {

                var postCode = jQuery("#PostCode");
                var postCodeLength = jQuery.trim(jQuery("#PostCode").attr("value")).length;

                postCode.next().empty();
                if (postCodeLength == 0) {
                    var span = jQuery("<span />").html('Postcode is required').addClass('errorMessage');
                    jQuery(span).insertAfter(postCode);
                    return false;
                }

                else
                    if (postCodeLength > 4 && postCodeLength < 9) {
                    var pcode = jQuery.trim(jQuery("#PostCode").attr("value").toUpperCase());
                    var rx = /[A-Z]{1,2}[0-9R][0-9A-Z]? *[0-9][A-Z]{2}/ ;
                    var matches = rx.exec(pcode);
                    if (matches === null) {
                        var span = jQuery("<span />").text('Invalid postcode').addClass('errorMessage');
                        jQuery(span).insertAfter(postCode);
                        return false;
                    }
                    return (matches != null && pcode == matches[0]);
                }
                    else {
                    var span = jQuery("<span />").text('Invalid postcode').addClass('errorMessage');
                    jQuery(span).insertAfter(postCode);
                    return false;
                }
            }
            catch(e) {
                alert('Error in getting the postcode: ' + e);
            }
        }
    };
})();
/* ]]> */