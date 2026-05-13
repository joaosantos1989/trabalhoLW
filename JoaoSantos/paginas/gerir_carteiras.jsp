<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- segurança de login ---
    if (autenticado == null || tipoConta == null) {
        // expulsa para o login
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return; // Interrompe a página
    }
%>

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
                String sql = "SELECT u.id_utilizador, u.username, c.saldo, c.tipoCarteiraID, c.id_carteira " +
                        "FROM utilizador u JOIN carteira c ON u.id_utilizador = c.id_utilizador ";

                Statement statementSaldo = conn.createStatement();
                ResultSet resultSaldo = statementSaldo.executeQuery(sql);

                while(resultSaldo.next()) {
        %>
        <tr>
            <td><strong><%= resultSaldo.getString("username") %></strong></td>
            <td class="text-success fw-bold"><%= resultSaldo.getDouble("saldo") %>€</td>
            <td class="text-center"> <!-- envia id do utilizador e id carteira -->
                <a href="pagina_admin.jsp?secao=gestao_carteira&id=<%= resultSaldo.getInt("id_utilizador") %>&id_cart=<%= resultSaldo.getInt("id_carteira") %>"
                   class="btn btn-sm btn-outline-primary">⚙️ Gerir</a>
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