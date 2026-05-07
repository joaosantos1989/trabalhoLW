<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<div class="container py-5 mt-5 text-center">
    <%
        String nomeUser = (String) session.getAttribute("utilizador");
        String idEncRecebido = request.getParameter("id_enc");

        if (idEncRecebido != null && nomeUser != null && conn != null) {
                int idEnc = Integer.parseInt(idEncRecebido);

            // soma o total da encomenda
            double totalPagar = 0;
            String sqlSoma = "SELECT SUM(preco_unitario * quantidade) AS total FROM ITEM_ENCOMENDA WHERE id_encomenda = ?";
            PreparedStatement statementSoma = conn.prepareStatement(sqlSoma);
            statementSoma.setInt(1, idEnc);
            ResultSet resultSoma = statementSoma.executeQuery();
            if(resultSoma.next()) totalPagar = resultSoma.getDouble("total");

            // procura o saldo do cliente
            String sqlSaldo = "SELECT c.id_carteira, c.saldo, c.tipoCarteiraId FROM CARTEIRA c, UTILIZADOR u " +
                    "WHERE c.id_utilizador = u.id_utilizador AND u.username = ?";
            PreparedStatement statementSaldo = conn.prepareStatement(sqlSaldo);
            statementSaldo.setString(1, nomeUser);
            ResultSet resultSaldo = statementSaldo.executeQuery();

            if (resultSaldo.next()) {
                int idCarteira = resultSaldo.getInt("id_carteira");
                double meuSaldo = resultSaldo.getDouble("saldo");
                int tipoCarteira = resultSaldo.getInt("tipoCarteiraId");

                // verifica se tem dinheiro suficiente
                if (meuSaldo >= totalPagar) {

                    // tira dinheiro ao cliente
                    String sqlRetira = "UPDATE CARTEIRA SET saldo = saldo - ? WHERE id_carteira = ?";
                    PreparedStatement statementRetira = conn.prepareStatement(sqlRetira);
                    statementRetira.setDouble(1, totalPagar);
                    statementRetira.setInt(2, idCarteira);
                    statementRetira.executeUpdate();


                    // deposita na conta da loja
                    Statement statementLoja = conn.createStatement();
                    // procuramos a carteira da loja
                    String sqlLoja = "SELECT id_carteira FROM CARTEIRA WHERE tipoCarteiraId = 2";
                    ResultSet resultLoja = statementLoja.executeQuery(sqlLoja);
                    if(resultLoja.next()) {
                        int idCartLoja = resultLoja.getInt("id_carteira");
                        String sqlDeposita = "UPDATE CARTEIRA SET saldo = saldo + ? WHERE id_carteira = ?";
                        PreparedStatement statementDeposita = conn.prepareStatement(sqlDeposita);
                        statementDeposita.setDouble(1, totalPagar);
                        statementDeposita.setInt(2, idCartLoja);
                        statementDeposita.executeUpdate();
                    }


                    // fecha a encomenda (muda de estado 0 para 1)
                    PreparedStatement statementFecha = conn.prepareStatement("UPDATE ENCOMENDA SET estado = 1, valor_total = ? WHERE id_encomenda = ?");
                    statementFecha.setDouble(1, totalPagar);
                    statementFecha.setInt(2, idEnc);
                    statementFecha.executeUpdate();

                    out.println("<h2 class='text-success'>✅ Pagamento Concluído!</h2>");
                    out.println("<p>Obrigado pela sua compra. O valor de " + totalPagar + "€ foi debitado.</p>");
                    out.println("<a href='pagina_principal.jsp' class='btn btn-success'>Voltar à Loja</a>");

                } else {
                    out.println("<h2 class='text-danger'>❌ Saldo Insuficiente</h2>");
                    out.println("<p>Precisa de " + totalPagar + "€, mas só tem " + meuSaldo + "€.</p>");
                    out.println("<a href='carteira.jsp' class='btn btn-warning'>Carregar Saldo</a>");
                }
            }
        }
    %>
</div>

<%@ include file="footer.jsp" %>