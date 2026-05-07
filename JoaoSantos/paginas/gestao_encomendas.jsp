<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

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
        <% //selecionamos as encomendas pendentes
            String sql = "SELECT e.id_encomenda, u.username, e.data_hora, e.valor_total " +
                    "FROM ENCOMENDA e, UTILIZADOR u " +
                    "WHERE e.id_utilizador = u.id_utilizador AND e.estado = 1";
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(sql);

            while(rs.next()) {
        %>
        <tr>
            <td><strong>#<%= rs.getInt("id_encomenda") %></strong></td>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getTimestamp("data_hora") %></td>
            <td class="text-success fw-bold"><%= rs.getDouble("valor_total") %>€</td>
            <td class="text-center">
                <a href="validar_encomenda.jsp?id_enc=<%= rs.getInt("id_encomenda") %>"
                   class="btn btn-sm btn-success">✅ Validar</a>

                <a href="cancelar_encomenda.jsp?id_enc=<%= rs.getInt("id_encomenda") %>"
                   class="btn btn-sm btn-danger">❌ Cancelar</a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>