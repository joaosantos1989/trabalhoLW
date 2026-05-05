<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<%
    //dados da sessão e do link
    String nomeUser = (String) session.getAttribute("utilizador");
    String idProd = request.getParameter("id");

    if (nomeUser != null && idProd != null && conn != null) {
        int idProduto = Integer.parseInt(idProd);

        // descobre o ID do utilizador
        String sqlUser = "SELECT id_utilizador FROM UTILIZADOR WHERE username = ?";
        PreparedStatement psUser = conn.prepareStatement(sqlUser);
        psUser.setString(1, nomeUser);
        ResultSet rsUser = psUser.executeQuery();

        if (rsUser.next()) {
            int idCliente = rsUser.getInt("id_utilizador");

            // verifica se já existe uma encomenda no carrinho (estado 0)
            int idEncomenda = 0;
            String sqlCheck = "SELECT id_encomenda FROM ENCOMENDA WHERE id_utilizador = ? AND estado = 0";
            PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
            psCheck.setInt(1, idCliente);
            ResultSet rsCheck = psCheck.executeQuery();

            if (rsCheck.next()) {
                idEncomenda = rsCheck.getInt("id_encomenda");
            } else {
                // se não existe, criamos uma nova encomenda
                String sqlNew = "INSERT INTO ENCOMENDA (id_utilizador, data_hora, valor_total, estado) VALUES (?, NOW(), 0, 0)";
                PreparedStatement psNew = conn.prepareStatement(sqlNew);
                psNew.setInt(1, idCliente);
                psNew.executeUpdate();

                // vai buscar o ID que o MySQL acabou de criar
                Statement stMax = conn.createStatement();
                ResultSet rsMax = stMax.executeQuery("SELECT MAX(id_encomenda) AS ultimo FROM ENCOMENDA WHERE id_utilizador = " + idCliente);
                if(rsMax.next()) {
                    idEncomenda = rsMax.getInt("ultimo");
                }
            }

            // adiciona o produto à encomenda (ITEM_ENCOMENDA)
            // primeiro buscamos o preço atual para ficar registado
            String sqlPreco = "SELECT preco FROM PRODUTO WHERE id_produto = ?";
            PreparedStatement psPreco = conn.prepareStatement(sqlPreco);
            psPreco.setInt(1, idProduto);
            ResultSet rsP = psPreco.executeQuery();

            if(rsP.next()){
                double precoActual = rsP.getDouble("preco");

                String sqlItem = "INSERT INTO ITEM_ENCOMENDA (id_encomenda, id_produto, quantidade, preco_unitario) VALUES (?, ?, 1, ?)";
                PreparedStatement psItem = conn.prepareStatement(sqlItem);
                psItem.setInt(1, idEncomenda);
                psItem.setInt(2, idProduto);
                psItem.setDouble(3, precoActual);
                psItem.executeUpdate();
            }
        }
        // redireciona para o carrinho
        response.sendRedirect("carrinho.jsp");
    } else {
        response.sendRedirect("login.jsp");
    }
%>