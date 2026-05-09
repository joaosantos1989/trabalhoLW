<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>


<div class="container mt-4">
    <!-- botões de controlo de admin -->
    <div class="d-flex flex-wrap gap-2 justify-content-center mb-4">
        <a href="pagina_admin.jsp?secao=produtos" class="btn btn-primary shadow-sm">📦 Produtos</a>
        <a href="pagina_admin.jsp?secao=encomendas" class="btn btn-primary shadow-sm">📋 Encomendas</a>
        <a href="pagina_admin.jsp?secao=utilizadores" class="btn btn-primary shadow-sm">👥 Utilizadores</a>
        <a href="pagina_admin.jsp?secao=alertas" class="btn btn-primary shadow-sm">🚨 Alertas</a>
        <a href="pagina_admin.jsp?secao=registos" class="btn btn-primary shadow-sm">📜 Registos</a>
    </div>

    <div id="secao-dashboard">
        <%
            String secao = request.getParameter("secao");
            String acao = request.getParameter("acao");
            String id = request.getParameter("id");

            if ("encomendas".equals(secao)) {
        %>
        <%@ include file="gestao_encomendas.jsp" %>
        <%
        } else if (secao == null || "utilizadores".equals(secao) || "editar_utilizador".equals(secao) || "aprovar_utilizador".equals(secao)) {
        %>
        <%@ include file="admin_utilizadores.jsp" %>
        <%
        } else if ("produtos".equals(secao) || "editar_produto".equals(secao) || "novo_produto".equals(secao)) {
        %>
        <%@ include file="admin_produtos.jsp" %>
        <%
        } else {
        %>
        <h2 class="text-center mt-5">⚠️ Seção '<%= secao %>' não encontrada.</h2>
        <%
            }
        %>
    </div>

<%@ include file="footer.jsp" %>