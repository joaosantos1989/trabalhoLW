<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<%
    String idItemRecebido = request.getParameter("id_item");//recebe o id do produto do carrinho

    if (idItemRecebido != null && conn != null) {
        int idItem = Integer.parseInt(idItemRecebido);

        // apaga o item da base de dados
        String sql = "DELETE FROM ITEM_ENCOMENDA WHERE id_item = ?";
        PreparedStatement statement = conn.prepareStatement(sql);
        statement.setInt(1, idItem);
        statement.executeUpdate();

        // volta para o carrinho já com o item removido
        response.sendRedirect("carrinho.jsp");
    }
%>