<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<%
    String idEncomenda = request.getParameter("id_enc"); //recebe o id da encomenda a validar

    if (idEncomenda != null && conn != null) {
        int idEnc = Integer.parseInt(idEncomenda);

        //soma o valor total da quantidade de cada produto da encomenda na tabela item_encomenda
        String sqlValor = "SELECT SUM(preco_unitario * quantidade) AS total_encomenda FROM ITEM_ENCOMENDA WHERE id_encomenda = ?";
        PreparedStatement statementValor = conn.prepareStatement(sqlValor);
        statementValor.setInt(1, idEnc);
        ResultSet resultValor = statementValor.executeQuery();

        double valorFinal = 0;
        if (resultValor.next()) {
            valorFinal = resultValor.getDouble("total_encomenda"); //acumula ao valor total da encomenda
        }

        // guarda o valor total e muda o estado para 1(preparada/não validada)
        String sqlUpdate = "UPDATE ENCOMENDA SET valor_total = ?, estado = 1 WHERE id_encomenda = ?";
        PreparedStatement statementUpdate = conn.prepareStatement(sqlUpdate);
        statementUpdate.setDouble(1, valorFinal);
        statementUpdate.setInt(2, idEnc);
        statementUpdate.executeUpdate();

        // Redireciona com mensagem de sucesso
        response.sendRedirect("carrinho.jsp?msg=pendente");
    }
%>