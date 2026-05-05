<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<%
    String nomeUser = (String) session.getAttribute("utilizador");
    String idProdStr = request.getParameter("id");

    if (nomeUser != null && idProdStr != null && conn != null) {
        try {
            int idProduto = Integer.parseInt(idProdStr);

            // 1. Descobrir o ID do utilizador
            PreparedStatement psUser = conn.prepareStatement("SELECT id_utilizador FROM UTILIZADOR WHERE username = ?");
            psUser.setString(1, nomeUser);
            ResultSet rsUser = psUser.executeQuery();

            if (rsUser.next()) {
                int idCliente = rsUser.getInt("id_utilizador");

                // 2. Verificar se este cliente já tem uma encomenda aberta (estado 0)
                int idEnc = 0;
                PreparedStatement psCheck = conn.prepareStatement("SELECT id_encomenda FROM ENCOMENDA WHERE id_utilizador = ? AND estado = 0");
                psCheck.setInt(1, idCliente);
                ResultSet rsCheck = psCheck.executeQuery();

                if (rsCheck.next()) {
                    idEnc = rsCheck.getInt("id_encomenda");
                } else {
                    // Se não tiver, criamos uma nova "mestra"
                    PreparedStatement psNew = conn.prepareStatement("INSERT INTO ENCOMENDA (id_utilizador, data_hora, valor_total, estado) VALUES (?, NOW(), 0, 0)", Statement.RETURN_GENERATED_KEYS);
                    psNew.setInt(1, idCliente);
                    psNew.executeUpdate();
                    ResultSet rsKeys = psNew.getGeneratedKeys();
                    if(rsKeys.next()) idEnc = rsKeys.getInt(1);
                }

                // 3. Adicionar o produto à tabela de detalhes (ITEM_ENCOMENDA)
                // Vamos buscar o preço para "congelar" o valor no momento da compra
                PreparedStatement psPreco = conn.prepareStatement("SELECT preco FROM PRODUTO WHERE id_produto = ?");
                psPreco.setInt(1, idProduto);
                ResultSet rsP = psPreco.executeQuery();
                if(rsP.next()){
                    double precoActual = rsP.getDouble("preco");
                    PreparedStatement psItem = conn.prepareStatement("INSERT INTO ITEM_ENCOMENDA (id_encomenda, id_produto, quantidade, preco_unitario) VALUES (?, ?, 1, ?)");
                    psItem.setInt(1, idEnc);
                    psItem.setInt(2, idProduto);
                    psItem.setDouble(3, precoActual);
                    psItem.executeUpdate();
                }
            }
            // 4. Depois de gravar, vai para a página do carrinho para mostrar a lista
            response.sendRedirect("carrinho.jsp");

        } catch (Exception e) {
            out.println("Erro ao adicionar: " + e.getMessage());
        }
    } else {
        // Se não estiver logado, manda para o login
        response.sendRedirect("login.jsp");
    }
%>