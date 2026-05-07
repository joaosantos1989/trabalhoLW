<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    String idEncRecebido = request.getParameter("id_enc"); //recebe o id da encomenda
    if (idEncRecebido != null && conn != null) {
        int idEnc = Integer.parseInt(idEncRecebido);

        // descobre quem é o cliente desta encomenda e qual o valor
        String sqlEnc = "SELECT id_utilizador, valor_total FROM ENCOMENDA WHERE id_encomenda = ?";
        PreparedStatement statementEnc = conn.prepareStatement(sqlEnc);
        statementEnc.setInt(1, idEnc);
        ResultSet resultEnc = statementEnc.executeQuery();

        if (resultEnc.next()) {
            int idCliente = resultEnc.getInt("id_utilizador");
            double total = resultEnc.getDouble("valor_total");

            // verifica saldo da carteira desse cliente específico
            String sqlSaldo = "SELECT id_carteira, saldo FROM CARTEIRA WHERE id_utilizador = ?";
            PreparedStatement statementSaldo = conn.prepareStatement(sqlSaldo);
            statementSaldo.setInt(1, idCliente);
            ResultSet resultSaldo = statementSaldo.executeQuery();

            if (resultSaldo.next()) {
                double saldoCli = resultSaldo.getDouble("saldo");
                int idCartCli = resultSaldo.getInt("id_carteira");

                if (saldoCli >= total) {
                    // tira dinheiro ao cliente
                    String sqlRetira = "UPDATE CARTEIRA SET saldo = saldo - ? WHERE id_carteira = ?";
                    PreparedStatement psT = conn.prepareStatement(sqlRetira);
                    psT.setDouble(1, total);
                    psT.setInt(2, idCartCli);
                    psT.executeUpdate();

                    // deposita na carteira da Loja (tipoCarteiraId = 2)
                    String sqlDeposita = "UPDATE CARTEIRA SET saldo = saldo + ? WHERE tipoCarteiraId = 2 LIMIT 1";
                    PreparedStatement psL = conn.prepareStatement(sqlDeposita);
                    psL.setDouble(1, total);
                    psL.executeUpdate();

                    // fecha a encomenda (Estado 2 = Paga e Validada)
                    String sqlValida = "UPDATE ENCOMENDA SET estado = 2 WHERE id_encomenda = ?";
                    PreparedStatement psF = conn.prepareStatement(sqlValida);
                    psF.setInt(1, idEnc);
                    psF.executeUpdate();

                    response.sendRedirect("gestao_encomendas.jsp?msg=sucesso");
                } else {
                    response.sendRedirect("gestao_encomendas.jsp?msg=sem_saldo");
                }
            }
        }
    }
%>