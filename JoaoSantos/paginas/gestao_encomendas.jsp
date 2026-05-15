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
    // identificar quem está logado
    int tipoUser = Integer.parseInt(tipoConta.toString());
    int idLogado = Integer.parseInt(session.getAttribute("idUtilizador").toString());
%>
<%-- alerta de encomenda submetida para o funcionário validar --%>
<% if ("sucesso".equals(request.getParameter("msg"))) { %>
<div class="container mt-2">
    <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
        <strong>📩 Encomenda Validada!</strong><br>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<%-- alerta de encomenda cancelada--%>
<% if ("cancelada".equals(request.getParameter("msg"))) { %>
<div class="container mt-2">
    <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
        <strong>📩 Encomenda Cancelada!</strong><br>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<%-- alerta de utilizador sem saldo suficiente--%>
<% if ("erro_saldo".equals(request.getParameter("msg"))) { %>
<div class="container mt-2">
    <div class="alert alert-danger alert-dismissible fade show text-center" role="alert">
        <strong>O utilizador não tem saldo suficiciente!</strong><br>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<div class="bg-white p-4 rounded shadow-sm border">
    <h2 class="text-primary border-bottom pb-2">📋 Gestão de Encomendas</h2>

    <table class="table table-striped mt-4 shadow-sm">
        <thead class="table-dark">
        <tr>
            <th>ID Único</th>
            <% if (tipoUser != 3) { %> <th>Cliente</th> <% } %> <%-- o cliente não ve o proprio nome--%>
            <th>Data</th>
            <th>Total</th>
            <th class="text-center">Ações</th>
        </tr>
        </thead>
        <tbody>
        <% //selecionamos as encomendas pendentes(estado 1)
            String sql;
            // Admin/Func (1 e 2) vêem tudo o que está pendente (estado 1)
            // Cliente (3) vê apenas as suas encomendas
            if (tipoUser == 3) {
                sql = "SELECT e.*, u.username FROM ENCOMENDA e JOIN UTILIZADOR u ON e.id_utilizador = u.id_utilizador " +
                        "WHERE e.id_utilizador = " + idLogado + " ORDER BY e.data_hora DESC";
            } else {
                sql = "SELECT e.*, u.username FROM ENCOMENDA e JOIN UTILIZADOR u ON e.id_utilizador = u.id_utilizador " +
                        "WHERE e.estado = 1 ORDER BY e.data_hora ASC";
            }
            Statement statement = conn.createStatement();
            ResultSet result = statement.executeQuery(sql);

            while(result.next()) {
                int idEnc = result.getInt("id_encomenda");
                int estado = result.getInt("estado");
        %>
        <tr>
            <td><strong>#<%= idEnc %></strong></td>
            <% if (tipoUser != 3) { %> <td><%= result.getString("username") %></td> <% } %>
            <td><%= result.getDate("data_hora") %></td>
            <td class="text-success fw-bold"><%= result.getDouble("valor_total") %>€</td>
            <td class="text-center">

                <%-- Ações do CLIENTE --%>
                <% if (tipoUser == 3) {
                    if (estado == 1) { // Só edita/cancela se estiver pendente %>
                        <a href="cancelar_encomenda.jsp?id_enc=<%= idEnc %>" class="btn btn-sm btn-outline-danger"
                           onclick="return confirm('Deseja cancelar esta encomenda?')">Cancelar</a>
                <% } %>

                <% } else { %>
                <%-- Ações do ADMIN / FUNCIONÁRIO --%>
                <a href="validar_encomenda.jsp?id_enc=<%= idEnc %>" class="btn btn-sm btn-success">Validar</a>
                <a href="cancelar_encomenda.jsp?id_enc=<%= idEnc %>" class="btn btn-sm btn-danger">Cancelar</a>
                <% } %>

            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>