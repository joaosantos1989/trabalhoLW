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

    int idUser = (int) session.getAttribute("idUtilizador");
    int idCartLogada = (int) session.getAttribute("idCarteira");

    double saldoAtual = 0;
    double totalACalcular = 0;
    int idDaEncomenda = 0;

    if (conn != null) {
        // procuramos saldo atual do cliente
        String sqlSaldo = "SELECT saldo FROM CARTEIRA WHERE id_carteira = ?";
        PreparedStatement psSaldo = conn.prepareStatement(sqlSaldo);
        psSaldo.setInt(1, idCartLogada);
        ResultSet rsSaldo = psSaldo.executeQuery();
        if (rsSaldo.next()) {
            saldoAtual = rsSaldo.getDouble("saldo");
        }
        rsSaldo.close();
        psSaldo.close();
    }
%>

<%-- alerta de encomenda submetida para o funcionário/admin validar --%>
<% if ("pendente".equals(request.getParameter("msg"))) { %>
<div class="container mt-2">
    <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
        <strong>📩 Encomenda Submetida!</strong><br>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

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
            if (conn != null) {
                // SQL para listar itens no carrinho (Estado 0)
                String sqlItems = "SELECT i.id_item, i.preco_unitario, p.nome, e.id_encomenda " +
                        "FROM ITEM_ENCOMENDA i, ENCOMENDA e, PRODUTO p " +
                        "WHERE i.id_encomenda = e.id_encomenda " +
                        "AND i.id_produto = p.id_produto " +
                        "AND e.estado = 0 AND e.id_utilizador = ?";

                PreparedStatement statement = conn.prepareStatement(sqlItems);
                statement.setInt(1, idUser);
                ResultSet result = statement.executeQuery();

                while (result.next()) {
                    idDaEncomenda = result.getInt("id_encomenda");
                    double preco = result.getDouble("preco_unitario");
                    totalACalcular += preco;
        %>
        <tr> <!-- informação do produto na tabela -->
            <td><%= result.getString("nome") %></td>
            <td><%= preco %>€</td>
            <td class="text-center">
                <%-- Link para remover apenas este item --%>
                <a href="remover_item.jsp?id_item=<%= result.getInt("id_item") %>" class="btn btn-sm btn-outline-danger">Remover</a>
            </td>
        </tr>
        <%
                }
                result.close();
                statement.close();
            }
        %>
        </tbody>
    </table>

    <div class="row mt-4 align-items-center">
        <div class="col-md-6">
            <a href="pagina_principal.jsp" class="btn btn-outline-secondary">← Continuar a Comprar</a>
            <div class="mt-2 text-muted">
                O teu saldo disponível: <strong><%= saldoAtual %>€</strong>
            </div>
        </div>

        <div class="col-md-6 text-end">
            <% if (totalACalcular > 0) { %>
            <h4>Total: <span class="text-success"><%= totalACalcular %>€</span></h4> <%-- mostra o saldo atual --%>

            <% if (saldoAtual >= totalACalcular) { %>
            <%-- se tem saldo suficiente--%>
            <a href="preparar_encomenda.jsp?id_enc=<%= idDaEncomenda %>" class="btn btn-success btn-lg shadow-sm">
                Confirmar Encomenda
            </a>
            <% } else { %>
            <%-- se não tem saldo suficiente, botão bloqueado  --%>
            <div class="text-danger mb-2 fw-bold">
                Saldo insuficiente! Faltam <%= (totalACalcular - saldoAtual) %>€
            </div>
            <button class="btn btn-secondary btn-lg shadow-sm" disabled title="Não tens saldo suficiente">
                Encomendar
            </button>
            <% } %>

            <% } else { %>
            <p class="text-muted">O carrinho está vazio.</p>
            <% } %>
        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>