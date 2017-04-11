<%--

  ADOBE CONFIDENTIAL
  __________________

   Copyright 2012 Adobe Systems Incorporated
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
          import="com.adobe.cq.betafeedback.FeedbackService,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Config,
                  com.day.cq.i18n.I18n,
                  org.apache.sling.commons.json.JSONArray,
                  java.util.Arrays,
                  java.util.Map,
                  java.util.Set,
                  org.apache.commons.lang3.StringUtils" %><%
    FeedbackService feedbackService = sling.getService(FeedbackService.class);
    if (feedbackService.isEnabled()) {
        Config cfg = new Config(resource);

        AttrBuilder attrs = new AttrBuilder(request, xssAPI);
        attrs.addClass(cfg.get("class", "endor-Button--feedback"));

        String url = feedbackService.getFeedbackUrl();
        if (StringUtils.isEmpty(url)) {
            url = request.getContextPath() + resource.getPath() + "/dialog.html";
        }
        attrs.addOther("href", url);

        Set<Map.Entry<String,Object>> entries = cfg.getProperties().entrySet();
        for (Map.Entry<String, Object> entry : entries) {
            String key = entry.getKey();
            if (!key.contains(":")) {
                Object value = entry.getValue();
                if (value instanceof Object[]) {
                    value = new JSONArray(Arrays.asList((Object[]) value));
                }
                attrs.addOther(key, value.toString());
            }
        }

        String buttonText = i18n.getVar(cfg.get("jcr:title", i18n.get("Beta Feedback")));
%>
<%--
The following clientlib include has caused weird shell3 issues in Chrome which is why I have added granite.ui.shell and
granite.ui.endor to the clientlib categories.

<ui:includeClientLib js="apps.betafeedback.button" />
--%>
<a is="coral-anchorbutton" variant="quiet" <%= attrs.build() %>><%= xssAPI.encodeForHTML(buttonText) %></a><%
    }
%>