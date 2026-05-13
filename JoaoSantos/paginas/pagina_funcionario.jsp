<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<%
    // --- segurança de login ---
    Object autenticado = session.getAttribute("autenticado");
    Object tipoConta = session.getAttribute("TipoConta");

    if (autenticado == null || tipoConta == null) {
        // expulsa para o login
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return; // Interrompe a página
    }
%>

<%
    String idSessao = session.getAttribute("idUtilizador").toString(); //precisamos do id do utilizador para gerir os seus dados
%>

<div class="container mt-4">
    <%-- botões de controlo de secao --%>
    <div class="d-flex flex-wrap gap-2 justify-content-center mb-4">
        <a href="pagina_funcionario.jsp?secao=encomendas" class="btn btn-primary shadow-sm">📋 Encomendas</a>
        <a href="pagina_funcionario.jsp?secao=carteira" class="btn btn-primary shadow-sm">💰 Gerir Carteiras</a>
        <a href="pagina_funcionario.jsp?secao=editar_utilizador&id=<%= idSessao %>" class="btn btn-primary shadow-sm">👤 Dados Pessoais</a>
    </div>

    <div id="secao-dashboard">
        <%
            String secao = request.getParameter("secao");
            // carteira de clientes
            if ("encomendas".equals(secao)) {
        %>
        <%@ include file="gestao_encomendas.jsp" %> <%-- gestão de encomendas --%>

        <%
        } else if ("carteira".equals(secao) || "gestao_carteira".equals(secao)) {
        %>
        <%@ include file="gerir_carteiras.jsp" %> <%-- gestão de carteiras --%>

        <%
        } else if ("editar_utilizador".equals(secao)) {
        %>
        <%@ include file="editar_utilizador.jsp" %> <%-- editar dados pessoais --%>

        <%
        } else { //default
        %>
        <%@ include file="gestao_encomendas.jsp" %> <%-- tabela de gestão de encomendas --%>

        <%
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>