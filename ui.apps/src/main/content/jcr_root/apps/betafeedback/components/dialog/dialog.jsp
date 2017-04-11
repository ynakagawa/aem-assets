<%--

  ADOBE CONFIDENTIAL
  __________________

   Copyright 2013 Adobe Systems Incorporated
   All Rights Reserved.

  NOTICE:  All information contained herein is, and remains
  the property of Adobe Systems Incorporated and its suppliers,
  if any.  The intellectual and technical concepts contained
  herein are proprietary to Adobe Systems Incorporated and its
  suppliers and are protected by trade secret or copyright law.
  Dissemination of this information or reproduction of this material
  is strictly forbidden unless prior written permission is obtained
  from Adobe Systems Incorporated.

--%><%
%><%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page session="false"
          import="java.util.Arrays,
                  java.util.List,
                  java.util.Map,
                  com.adobe.cq.betafeedback.FeedbackService,
                  com.adobe.granite.ui.components.Config,
                  com.day.cq.i18n.I18n,
                  com.day.cq.mailer.MessageGateway,
                  org.apache.commons.lang3.StringUtils" %><%
    FeedbackService feedbackService = sling.getService(com.adobe.cq.betafeedback.FeedbackService.class);
    if (!feedbackService.isEnabled()) {
        log.error("Feedback form is disabled.");
        response.sendError(404);
        return;
    }

    Config cfg = new Config(resource);

    String reporterName = StringUtils.defaultString(feedbackService.getReporterName(slingRequest));
    String reporterEmail = StringUtils.defaultString(feedbackService.getReporterEmail(slingRequest));
    String customer = StringUtils.defaultString(feedbackService.getCustomer(slingRequest));
    boolean showType = !"false".equals(request.getParameter("showType"));
    String description = StringUtils.defaultString(request.getParameter("description"));

    String pageTitle = i18n.getVar(cfg.get("jcr:title", i18n.get("Feedback on Beta")));
    String pageDescription = i18n.getVar(cfg.get("jcr:description", ""));

%>
<!DOCTYPE html>
<html>
<head>
    <title><%=pageTitle%></title>
    <cq:includeClientLib categories="apps.betafeedback.dialog" />
</head>
<body class="coral--light">

    <coral-dialog id="feedback-dialog">
        <form action="<%=resource.getPath() + ".json"%>" method="post">
            <input type="hidden" name="_charset_" value="UTF-8">
        <coral-dialog-header>
            <%=pageTitle%>
        </coral-dialog-header>
        <coral-dialog-content class="coral-Form coral-Form--aligned">

            <div class="messages">
                <% if (sling.getService(MessageGateway.class) == null) { %>
                <coral-alert variant="error">
                    <coral-alert-content><%= i18n.get("The mail service is not configured.") %></coral-alert-content>
                </coral-alert>
                <% } %>
            </div>

            <div class="coral-Form-fieldwrapper">
                <label class="coral-Form-fieldlabel<%= !StringUtils.isEmpty(reporterName) ? " is-disabled" : "" %>"><%= i18n.get("Name") %></label>
                <input is="coral-textfield" name="name" value="<%= xssAPI.encodeForHTMLAttr(reporterName)%>" <%= !StringUtils.isEmpty(reporterName) ? " disabled" : "" %>>
            </div>
            <div class="coral-Form-fieldwrapper">
                <label class="coral-Form-fieldlabel<%= !StringUtils.isEmpty(reporterEmail) ? " is-disabled" : "" %>"><%= i18n.get("Email") %></label>
                <input is="coral-textfield" name="email" value="<%= xssAPI.encodeForHTMLAttr(reporterEmail)%>"<%= !StringUtils.isEmpty(reporterEmail) ? " disabled" : "" %>>
            </div>
            <div class="coral-Form-fieldwrapper">
                <label class="coral-Form-fieldlabel<%= !StringUtils.isEmpty(customer) ? " is-disabled" : "" %>"><%= i18n.get("Company") %></label>
                <input is="coral-textfield" name="customer" value="<%= xssAPI.encodeForHTMLAttr(customer)%>"<%= !StringUtils.isEmpty(customer) ? " disabled" : "" %>>
            </div><%

            if (showType) {
        %><label class="coral-Form-fieldlabel"><%= i18n.get("Type") %></label>
            <div class="coral-Form-field coral-RadioGroup">
                <coral-radio name="type" value="Bug">
                    <%=i18n.get("Defect", "issue type")%>
                </coral-radio>
                <coral-radio name="type" value="Improvement" checked>
                    <%=i18n.get("Enhancement", "issue type")%>
                </coral-radio>
                <coral-radio name="type" value="Task">
                    <%=i18n.get("Question", "issue type")%>
                </coral-radio>
            </div><%
            }
        %>

            <cq:include path="<%=resource.getPath() + "/additionalFields"%>" resourceType="granite/ui/components/foundation/contsys" />

            <div class="coral-Form-fieldwrapper">
                <label class="coral-Form-fieldlabel"><%= i18n.get("Title") %></label>
                <input is="coral-textfield" name="title">
            </div>

            <label class="coral-Form-fieldlabel"><%= i18n.get("Description") %></label>
            <textarea is="coral-textarea" name="description" rows="4"><%= xssAPI.encodeForHTML(description) %></textarea>

            <div class="coral-Form-fieldwrapper">
                <label class="coral-Form-fieldlabel"><%= i18n.get("Attachments") %></label>
                <input class="coral-Form-field" type="file" name="attachments" multiple>
            </div>

            <% if (!StringUtils.isEmpty(pageDescription)) { %>
            <div class="coral-Form-fieldwrapper"><%= pageDescription %></div>
            <% } %>

        </coral-dialog-content>
        <coral-dialog-footer>
            <button is="coral-button" type="reset" coral-close><%=i18n.get("Close")%></button>
            <button is="coral-button" type="submit" variant="primary"><%=i18n.get("Send")%></button>
        </coral-dialog-footer>

            <%
                List<String> ignoredParams = Arrays.asList("description");
                Map<String, String[]> params = request.getParameterMap();
                for (Map.Entry<String, String[]> param : params.entrySet()) {
                    if (!ignoredParams.contains(param.getKey())) {
                        for (String value : param.getValue()) {
            %><input type="hidden" name="<%=xssAPI.encodeForHTML(param.getKey())%>" value="<%=xssAPI.encodeForHTMLAttr(value)%>"><%
                    }
                }
            }
        %>
        </form>
    </coral-dialog>

</body>
</html>