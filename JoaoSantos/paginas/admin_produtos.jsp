<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- remover produto da bd ---
    acao = request.getParameter("acao");
    String idParaRemover = request.getParameter("id");

    if ("remover".equals(acao) && idParaRemover != null && conn != null) {
        String sqlDelete = "DELETE FROM PRODUTO WHERE id_produto = ?";
        PreparedStatement statementDelete = conn.prepareStatement(sqlDelete);
        statementDelete.setInt(1, Integer.parseInt(idParaRemover));
        statementDelete.executeUpdate();

        out.println("<div class='alert alert-danger text-center mt-2'>🗑️ Produto removido com sucesso!</div>");
    }

        if ("novo_produto".equals(secao)) {
    %>
        <%@ include file="novo_produto.jsp" %>
    <%
    } else if ("editar_produto".equals(secao)) {
    %>
        <%@ include file="editar_produto.jsp" %>
    <%
    } else {
        // --- 3. SE NÃO FOR NOVO NEM EDITAR, MOSTRA A TABELA ---
    %>
    <%-- Cabeçalho --%>
    <div class="bg-white p-4 rounded shadow-sm border mt-3">

        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
            <h2 class="text-primary mb-0">📋 Gestão de Produtos</h2>
            <a href="pagina_admin.jsp?secao=novo_produto" class="btn btn-success">➕ Novo Produto</a>
        </div>

    <%-- Ordenação --%>
    <div class="d-flex justify-content-end align-items-center mb-3">
        <span class="small fw-bold me-2">ORDENAR:</span>
        <a href="pagina_admin.jsp?secao=produtos&ordem=nome" class="btn btn-sm btn-outline-secondary me-1">Nome</a>
        <a href="pagina_admin.jsp?secao=produtos&ordem=barato" class="btn btn-sm btn-outline-secondary me-1">€ Min</a>
        <a href="pagina_admin.jsp?secao=produtos&ordem=caro" class="btn btn-sm btn-outline-secondary">€ Max</a>
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
                String sql = "SELECT * FROM PRODUTO ORDER BY nome ASC";

                if ("barato".equals(ordem)) sql = "SELECT * FROM PRODUTO ORDER BY preco ASC";
                else if ("caro".equals(ordem)) sql = "SELECT * FROM PRODUTO ORDER BY preco DESC";

                PreparedStatement statementOrd = conn.prepareStatement(sql);
                ResultSet resultOrd = statementOrd.executeQuery();

                while(resultOrd.next()) {
                    int idProd = resultOrd.getInt("id_produto");
        %>
        <tr>
            <td><strong><%= resultOrd.getString("nome") %></strong></td>
            <td class="text-success fw-bold"><%= resultOrd.getDouble("preco") %>€</td>
            <td class="text-center">
                <%-- Link para Editar --%>
                <a href="pagina_admin.jsp?secao=editar_produto&id=<%= idProd %>"
                   class="btn btn-sm btn-outline-primary">✏️</a>

                <%-- Link para Remover --%>
                <a href="pagina_admin.jsp?secao=produtos&acao=remover&id=<%= idProd %>"
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