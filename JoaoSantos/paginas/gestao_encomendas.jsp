<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

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

<div class="container mt-5">
    <h2 class="text-primary border-bottom pb-2">📋 Gestão de Encomendas Pendentes</h2>

    <table class="table table-striped mt-4 shadow-sm">
        <thead class="table-dark">
        <tr>
            <th>ID Único</th>
            <th>Cliente</th>
            <th>Data</th>
            <th>Total</th>
            <th class="text-center">Ações</th>
        </tr>
        </thead>
        <tbody>
        <% //selecionamos as encomendas pendentes(estado 1)
            String sql = "SELECT e.id_encomenda, u.username, e.data_hora, e.valor_total " +
                    "FROM ENCOMENDA e, UTILIZADOR u " +
                    "WHERE e.id_utilizador = u.id_utilizador AND e.estado = 1";
            Statement statement = conn.createStatement();
            ResultSet result = statement.executeQuery(sql);

            while(result.next()) {
        %>
        <tr>
            <td><strong>#<%= result.getInt("id_encomenda") %></strong></td>
            <td><%= result.getString("username") %></td>
            <td><%= result.getDate("data_hora") %></td>
            <td class="text-success fw-bold"><%= result.getDouble("valor_total") %>€</td>
            <td class="text-center">
                <a href="validar_encomenda.jsp?id_enc=<%= result.getInt("id_encomenda") %>"
                   class="btn btn-sm btn-success">✅ Validar</a>

                <a href="cancelar_encomenda.jsp?id_enc=<%= result.getInt("id_encomenda") %>"
                   class="btn btn-sm btn-danger">❌ Cancelar</a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>