<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    if ("gestao_carteira".equals(secao)) { //formulário para adicionar ou retirar dinheiro
%>
<%@ include file="gestao_carteira.jsp" %>

<%
} else { //tabela que lista os clientes e o seu saldo atual
%>

<div class="bg-white p-4 rounded shadow-sm border mt-3">
    <h2 class="text-primary border-bottom pb-2">💰 Gestão de Carteira</h2>

    <%-- alerta de operação --%>
    <% if ("saldo_ok".equals(request.getParameter("msg"))) { %>
    <div class="container mt-2">
        <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
            <strong>✅ Operação realizada com sucesso!</strong><br>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </div>
    <% } %>

    <table class="table table-hover mt-3 border">
        <thead class="table-dark">
        <tr>
            <th>Cliente</th>
            <th>Saldo Atual</th>
            <th class="text-center">Ação</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (conn != null) {
                // procuramos os utilizadores e o seu saldo
                String sql = "SELECT u.id_utilizador, u.username, c.saldo, c.tipoCarteiraID " +
                        "FROM utilizador u, carteira c " +
                        "WHERE u.id_utilizador = c.id_utilizador";

                Statement statementSaldo = conn.createStatement();
                ResultSet resultSaldo = statementSaldo.executeQuery(sql);

                while(resultSaldo.next()) {
                    int tipoCart = resultSaldo.getInt("tipoCarteiraID");
        %>
        <tr>
            <td>
                <strong><%= resultSaldo.getString("username") %></strong>
                <%-- Se for a carteira tipo 2, da loja--%>
                <% if (tipoCart == 2) { %>
                <span class="badge bg-warning text-dark">LOJA</span>
                <% } %>
            </td>
            <td class="text-success fw-bold"><%= resultSaldo.getDouble("saldo") %>€</td>
            <td class="text-center">
                <a href="pagina_admin.jsp?secao=gestao_carteira&id=<%= resultSaldo.getInt("id_utilizador") %>"
                   class="btn btn-sm btn-outline-primary">
                    ⚙️ Gerir Carteira
                </a>
            </td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>
</div>

<% } %>