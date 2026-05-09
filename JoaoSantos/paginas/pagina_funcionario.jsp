<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<div class="container mt-4">
    <%-- botões de controlo de secao --%>
    <div class="d-flex flex-wrap gap-2 justify-content-center mb-4">
        <a href="pagina_funcionario.jsp?secao=encomendas" class="btn btn-primary shadow-sm">📋 Encomendas</a>
        <a href="pagina_funcionario.jsp?secao=saldo" class="btn btn-primary shadow-sm">💰 Saldo de Clientes</a>
        <a href="pagina_funcionario.jsp?secao=pessoal" class="btn btn-primary shadow-sm">👤 Dados Pessoais</a>
    </div>

    <div id="secao-dashboard" class="bg-white p-4 rounded shadow-sm border">
        <%
            String secao = request.getParameter("secao");

            // saldo de clientes
            if ("saldo".equals(secao)) {
        %>
        <h2 class="text-primary border-bottom pb-2 mb-4">💰 Gestão de Saldo de Clientes</h2>
        <div class="alert alert-info"> (Em construção).</div>
        <%
            // dados pessoais
        } else if ("pessoal".equals(secao)) {
        %>
        <h2 class="text-primary border-bottom pb-2 mb-4">👤 Os Meus Dados Pessoais</h2>
        <div class="alert alert-info"> (Em construção).</div>
        <%
            // 3. SEÇÃO POR DEFEITO: ENCOMENDAS (Se for null ou "encomendas")
        } else {
        %>
        <%@ include file="gestao_encomendas.jsp" %> <%-- tabela de gestão de encomendas --%>
        <%
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>