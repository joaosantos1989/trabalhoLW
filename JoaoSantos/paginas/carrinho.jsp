<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<div class="container mt-5">
    <h2 class="text-success border-bottom pb-2">🛒 O Meu Carrinho</h2>

    <table class="table mt-3 shadow-sm bg-white">
        <thead class="table-light">
        <tr>
            <th>Produto</th>
            <th>Preço Unitário</th>
            <th class="text-center">Ação</th>
        </tr>
        </thead>
        <tbody>
        <%
            String nomeUser = (String) session.getAttribute("utilizador");
            double totalACalcular = 0;
            int idDaEncomenda = 0;

            if (conn != null && nomeUser != null) {
                // procuramos os produtos da encomenda que ainda não foram pagos(estado 0) do utilizador
                String sql = "SELECT i.id_item, i.preco_unitario, p.nome, e.id_encomenda " +
                        "FROM ITEM_ENCOMENDA i, ENCOMENDA e, PRODUTO p, UTILIZADOR u " +
                        "WHERE i.id_encomenda = e.id_encomenda " +
                        "AND i.id_produto = p.id_produto " +
                        "AND e.id_utilizador = u.id_utilizador " +
                        "AND e.estado = 0 " +
                        "AND u.username = ?";


                PreparedStatement statement = conn.prepareStatement(sql);
                statement.setString(1, nomeUser);
                ResultSet result = statement.executeQuery();

                // Se não houver produtos, a tabela ficará vazia
                while (result.next()) {
                    idDaEncomenda = result.getInt("id_encomenda");
                    double preco = result.getDouble("preco_unitario");
                    totalACalcular += preco;
        %>
        <tr>
            <td><%= result.getString("nome") %></td>
            <td><%= preco %>€</td>
            <td class="text-center">
                <%-- Link para remover apenas este item --%>
                <a href="remover_item.jsp?id_item=<%= result.getInt("id_item") %>" class="btn btn-sm btn-outline-danger">Remover</a>
            </td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

    <div class="row mt-4">
        <div class="col-md-6">
            <a href="pagina_principal.jsp" class="btn btn-outline-secondary">← Continuar a Comprar</a>
        </div>
        <div class="col-md-6 text-end">
            <% if (totalACalcular > 0) { %>
            <h4>Total a pagar: <span class="text-success"><%= totalACalcular %>€</span></h4>
            <%-- envia o ID da encomenda para a página de pagamento --%>
            <a href="enviar_encomenda.jsp?id_enc=<%= idDaEncomenda %>" class="btn btn-success btn-lg shadow-sm">Encomendar</a>
            <% } else { %>
            <p class="text-muted">O carrinho está vazio.</p>
            <% } %>
        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>