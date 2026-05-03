<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    session.invalidate();

    out.println("<h1 style='color:green; text-align:center; margin-top:50px;'>A fazer logout...</h1>");

    response.setHeader("Refresh", "3; URL=pagina_principal.jsp");
%>