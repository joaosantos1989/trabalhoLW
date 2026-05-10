<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<%
    int meuId = (int) session.getAttribute("idUtilizador");
    String secao = request.getParameter("secao");
%>

<div class="container mt-4">
    <%-- Botões de Navegação --%>
    <div class="d-flex flex-wrap gap-2 justify-content-center mb-4">
        <a href="pagina_cliente.jsp?secao=encomendas" class="btn btn-primary shadow-sm">📋 Encomendas</a>
        <a href="pagina_cliente.jsp?secao=carteira&id=<%= meuId %>" class="btn btn-primary shadow-sm">💰 Gerir Carteira</a>
        <a href="pagina_cliente.jsp?secao=editar_utilizador&id=<%= meuId %>" class="btn btn-primary shadow-sm">👤 Dados Pessoais</a>
    </div>

        <%-- alerta de operação --%>
    <% if ("saldo_ok".equals(request.getParameter("msg"))) { %>
        <div class="container mt-2">
            <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
                <strong>✅ Operação realizada com sucesso!</strong><br>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </div>
    <% } %>

    <div id="secao-dashboard">
        <%
            if ("encomendas".equals(secao)) {
        %>
        <%@ include file="gestao_encomendas.jsp" %>

        <%
        } else if ("carteira".equals(secao)) {
        %>
        <%@ include file="gestao_carteira.jsp" %>

        <%
        } else if ("editar_utilizador".equals(secao)) {
        %>
        <%@ include file="editar_utilizador.jsp" %>

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