<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%-- alertas --%>
<%-- alerta produto adicionado --%>
<% if ("adicionado".equals(request.getParameter("msg"))) { %>
<div class="container mt-2">
    <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
        <strong>📦 Produto adicionado!</strong><br>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<%-- alerta produto removido --%>
<% if ("removido".equals(request.getParameter("msg"))) { %>
<div class="container mt-2">
    <div class="alert alert-danger alert-dismissible fade show text-center" role="alert">
        <strong>📦 Produto removido!</strong><br>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<%-- alerta produto editado --%>
<% if ("editado".equals(request.getParameter("msg"))) { %>
<div class="container mt-2">
    <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
        <strong>📦 Produto editado!</strong><br>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<%// --- remover produto da bd ---
    acao = request.getParameter("acao");
    String idParaRemover = request.getParameter("id");

    if ("remover".equals(acao) && idParaRemover != null && conn != null) {
        String sqlDelete = "DELETE FROM PRODUTO WHERE id_produto = ?";
        PreparedStatement statementDelete = conn.prepareStatement(sqlDelete);
        statementDelete.setInt(1, Integer.parseInt(idParaRemover));
        statementDelete.executeUpdate();

        response.sendRedirect("pagina_admin.jsp?secao=produtos&msg=removido");
    }

        if ("novo_produto".equals(secao)) {
    %>
        <%@ include file="novo_produto.jsp" %> <!-- inserir novo produto na bd -->
    <%
    } else if ("editar_produto".equals(secao)) {
    %>
        <%@ include file="editar_produto.jsp" %> <!-- editar produto na bd -->
    <%
    } else {
        // --- se a secao não for adicionar, remover ou editar produto mostra a tabela de produtos ---
    %>
    <%-- Cabeçalho --%>
    <div class="bg-white p-4 rounded shadow-sm border mt-3">

        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
            <h2 class="text-primary mb-0">📋 Gestão de Produtos</h2>
            <a href="pagina_admin.jsp?secao=novo_produto" class="btn btn-success">Novo Produto</a>
        </div>

    <%-- Ordenação --%>
    <div class="d-flex justify-content-end align-items-center mb-3">
        <span class="small fw-bold me-2">Ordenar por:</span>
        <a href="pagina_admin.jsp?secao=produtos&ordem=nome" class="btn btn-sm btn-outline-success">Nome</a>
        <a href="pagina_admin.jsp?secao=produtos&ordem=barato" class="btn btn-sm btn-outline-success">€ Min</a>
        <a href="pagina_admin.jsp?secao=produtos&ordem=caro" class="btn btn-sm btn-outline-success">€ Max</a>
    </div>

    <table class="table table-hover border">
        <thead class="table-dark">
        <tr>
            <th>Nome</th>
            <th>Preço</th>
            <th class="text-center">Ações</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (conn != null) {
                String ordem = request.getParameter("ordem");
                String sqlSelect = "SELECT * FROM PRODUTO ORDER BY nome ASC";

                if ("barato".equals(ordem)) sqlSelect = "SELECT * FROM PRODUTO ORDER BY preco ASC";
                else if ("caro".equals(ordem)) sqlSelect = "SELECT * FROM PRODUTO ORDER BY preco DESC";

                PreparedStatement statementSelect = conn.prepareStatement(sqlSelect);
                ResultSet resultSelect = statementSelect.executeQuery();

                while(resultSelect.next()) {
                    int idProduto = resultSelect.getInt("id_produto");
        %>
        <tr>
            <td><strong><%= resultSelect.getString("nome") %></strong></td>
            <td class="text-success fw-bold"><%= resultSelect.getDouble("preco") %>€</td>
            <td class="text-center">
                <%-- Link para Editar --%>
                <a href="pagina_admin.jsp?secao=editar_produto&id=<%= idProduto %>"
                   class="btn btn-sm btn-outline-primary">✏️</a>

                <%-- Link para Remover --%>
                <a href="pagina_admin.jsp?secao=produtos&acao=remover&id=<%= idProduto %>"
                   class="btn btn-sm btn-outline-danger"
                   onclick="return confirm('Apagar este produto permanentemente?')">🗑️</a>
            </td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>
</div>
<%
    }
%>