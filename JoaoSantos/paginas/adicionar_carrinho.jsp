<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    //dados da sessão e do link
    int idUser = (int) session.getAttribute("idUtilizador");
    String idProd = request.getParameter("id");

    if (idProd != null && conn != null) {
        int idProduto = Integer.parseInt(idProd);

        // verifica se já existe uma encomenda no carrinho (estado 0)
        int idEncomenda = 0;
        String sqlCheck = "SELECT id_encomenda FROM ENCOMENDA WHERE id_utilizador = ? AND estado = 0";
        PreparedStatement statementCheck = conn.prepareStatement(sqlCheck);
        statementCheck.setInt(1, idUser);
        ResultSet resultCheck = statementCheck.executeQuery();

        if (resultCheck.next()) { //se existe usamos o id da encomenda atual
            idEncomenda = resultCheck.getInt("id_encomenda");
        } else {
            // se não existe, criamos uma nova encomenda
            String sqlNew = "INSERT INTO ENCOMENDA (id_utilizador, data_hora, valor_total, estado) VALUES (?, NOW(), 0, 0)";
            PreparedStatement statementNew = conn.prepareStatement(sqlNew);
            statementNew.setInt(1, idUser);
            statementNew.executeUpdate();

            // vai buscar o id da ultima encomenda criada através do maior id, por causa do autoincrement do id
            String sqlRecent = "SELECT MAX(id_encomenda) AS ultima FROM ENCOMENDA WHERE id_utilizador = ";
            Statement statementRecent = conn.createStatement();
            ResultSet resultRecent = statementRecent.executeQuery( sqlRecent + idUser);
            if(resultRecent.next()) {
                idEncomenda = resultRecent.getInt("ultima");
            }
        }


        // procuramos o preço atual para ficar registado
        String sqlPreco = "SELECT preco FROM PRODUTO WHERE id_produto = ?";
        PreparedStatement precoAtual = conn.prepareStatement(sqlPreco);
        precoAtual.setInt(1, idProduto);
        ResultSet resultPreco = precoAtual.executeQuery();

        // adiciona o produto à encomenda (ITEM_ENCOMENDA)
        if(resultPreco.next()){
            double precoActual = resultPreco.getDouble("preco");

            String sqlItem = "INSERT INTO ITEM_ENCOMENDA (id_encomenda, id_produto, quantidade, preco_unitario) VALUES (?, ?, 1, ?)";
            PreparedStatement statementItem = conn.prepareStatement(sqlItem);
            statementItem.setInt(1, idEncomenda);
            statementItem.setInt(2, idProduto);
            statementItem.setDouble(3, precoActual);
            statementItem.executeUpdate();
        }
        // redireciona para o carrinho
        response.sendRedirect("pagina_principal.jsp?adicionado=add");
    } else {
        response.sendRedirect("login.jsp?needLogin=n"); //redireciona para login se tentar adicionar um produto sem estar autenticado
    }
%>