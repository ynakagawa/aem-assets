<%@ page import="com.day.cq.commons.Doctype" %><%
%><%--
  Copyright 1997-2008 Day Management AG
  Barfuesserplatz 6, 4001 Basel, Switzerland
  All Rights Reserved.

  This software is the confidential and proprietary information of
  Day Management AG, ("Confidential Information"). You shall not
  disclose such Confidential Information and shall use it only in
  accordance with the terms of the license agreement you entered into
  with Day.

  ==============================================================================

  Includes the scripts and css to be included in the head tag

  ==============================================================================
  Yuji
--%><%@page session="false" contentType="text/html; charset=utf-8"%>
<%@include file="/libs/foundation/global.jsp" %><%

    currentDesign.writeCssIncludes(pageContext);
    String xs = Doctype.isXHTML(request) ? "/" : "";

%><link href="/etc/designs/assetshare/ui.widgets.css" rel="stylesheet" type="text/css"<%=xs%>>
<link href="/libs/wcm/core/content/damadmin.ico" type="image/vnd.microsoft.icon" rel="shortcut icon"<%=xs%>>
<link href="/libs/wcm/core/content/damadmin.ico" type="image/vnd.microsoft.icon" rel="icon"<%=xs%>>
<cq:includeClientLib categories="cq.dam.assetshare.cms"/>