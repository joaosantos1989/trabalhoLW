<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<%
    String idSessao = session.getAttribute("idUtilizador").toString();
%>

<div class="container mt-4">
    <%-- botões de controlo de secao --%>
    <div class="d-flex flex-wrap gap-2 justify-content-center mb-4">
        <a href="pagina_cliente.jsp?secao=encomendas" class="btn btn-primary shadow-sm">📋 Encomendas</a>
        <a href="pagina_cliente.jsp?secao=carteira" class="btn btn-primary shadow-sm">💰 Carteira</a>
        <a href="pagina_cliente.jsp?secao=editar_utilizador&id=<%= idSessao %>" class="btn btn-primary shadow-sm">👤 Dados Pessoais</a>
    </div>

    <div id="secao-dashboard" class="bg-white p-4 rounded shadow-sm border">
        <%
            String secao = request.getParameter("secao");
            // carteira
            if ("carteira".equals(secao)) {
        %>
        <h2 class="text-primary border-bottom pb-2 mb-4">💰 carteira</h2>
        <div class="alert alert-info"> (Em construção).</div>
        <%
            // dados pessoais
        } else if ("editar_utilizador".equals(secao)) {
        %>
        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
            <a href="pagina_cliente.jsp?secao=encomendas" class="btn btn-sm btn-outline-secondary">← Voltar</a>
        </div>
        <%@ include file="editar_utilizador.jsp" %> <%-- editar dados pessoais --%>
        <%
        } else {
        %>
        <%@ include file="gestao_encomendas.jsp" %> <%-- tabela de gestão de encomendas --%>
        <%
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>