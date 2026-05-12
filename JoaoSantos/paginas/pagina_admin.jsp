<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<%
    // --- segurança de login ---
    Object autenticado = session.getAttribute("autenticado");
    Object tipoConta = session.getAttribute("TipoConta");

    if (autenticado == null || tipoConta == null || (int) tipoConta != 1) {
        // Se não for admin, expulsa para o login
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return; // Interrompe a página
    }
%>

<div class="container mt-4">
    <!-- botões de controlo de admin -->
    <div class="d-flex flex-wrap gap-2 justify-content-center mb-4">
        <a href="pagina_admin.jsp?secao=produtos" class="btn btn-primary shadow-sm">📦 Produtos</a>
        <a href="pagina_admin.jsp?secao=encomendas" class="btn btn-primary shadow-sm">📋 Encomendas</a>
        <a href="pagina_admin.jsp?secao=utilizadores" class="btn btn-primary shadow-sm">👥 Utilizadores</a>
        <a href="pagina_admin.jsp?secao=carteira" class="btn btn-primary shadow-sm">💰 Gerir Carteiras</a>
        <a href="pagina_admin.jsp?secao=alertas" class="btn btn-primary shadow-sm">🚨 Alertas</a>
        <a href="pagina_admin.jsp?secao=registos" class="btn btn-primary shadow-sm">📜 Registos</a>
    </div>

    <div id="secao-dashboard">
        <%
            String secao = request.getParameter("secao");
            String acao = request.getParameter("acao");
            String id = request.getParameter("id");

            if ("produtos".equals(secao) || "editar_produto".equals(secao) || "novo_produto".equals(secao)) {
        %>
        <%@ include file="admin_produtos.jsp" %> <!-- gestão de produtos -->

        <%
             } else if ("encomendas".equals(secao)) {
        %>
        <%@ include file="gestao_encomendas.jsp" %> <!-- gestão de encomendas -->

        <%
            } else if (secao == null || "utilizadores".equals(secao) || "editar_utilizador".equals(secao) || "aprovar_utilizador".equals(secao)) {
        %>
        <%@ include file="admin_utilizadores.jsp" %> <!-- gestão de utilizadores -->

        <%
            } else if ("carteira".equals(secao) || "gestao_carteira".equals(secao)) {
        %>
        <%@ include file="gerir_carteiras.jsp" %> <!-- gestão de carteiras-->

        <%
            } else if ("alertas".equals(secao)) {
        %>
            <div class="alert alert-info"> Seção <%=secao%> (Em construção).</div> <!-- gestão de alertas -->

        <%
            } else if ("registos".equals(secao)) {
        %>
        <%@ include file="admin_registos.jsp" %> <!-- gestão de movimentos -->

        <%
            } else {
        %>
            <div class="alert alert-info"> Seção <%=secao%> não encontrada! </div>

        <%
                }
        %>
    </div>

<%@ include file="footer.jsp" %>