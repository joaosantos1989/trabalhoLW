<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<div class="container py-5 mt-5 text-center">
    <%
        String nomeUser = (String) session.getAttribute("utilizador");
        String idEncRecebido = request.getParameter("id_enc");

        if (nomeUser != null && idEncRecebido != null && conn != null) {
                int idEnc = Integer.parseInt(idEncRecebido);

            // soma o total da encomenda
            double totalPagar = 0;
            String sqlSoma = "SELECT SUM(preco_unitario * quantidade) AS total FROM ITEM_ENCOMENDA WHERE id_encomenda = ?";
            PreparedStatement psSoma = conn.prepareStatement(sqlSoma);
            psSoma.setInt(1, idEnc);
            ResultSet rsSoma = psSoma.executeQuery();
            if(rsSoma.next()) totalPagar = rsSoma.getDouble("total");

            // bprocura o saldo do cliente
            String sqlSaldo = "SELECT c.id_carteira, c.saldo FROM CARTEIRA c, UTILIZADOR u WHERE c.id_utilizador = u.id_utilizador AND u.username = ?";
            PreparedStatement psSaldo = conn.prepareStatement(sqlSaldo);
            psSaldo.setString(1, nomeUser);
            ResultSet rsSaldo = psSaldo.executeQuery();

            if (rsSaldo.next()) {
                int idCarteira = rsSaldo.getInt("id_carteira");
                double meuSaldo = rsSaldo.getDouble("saldo");

                // verifica se tem dinheiro suficiente
                if (meuSaldo >= totalPagar) {

                    // tira dinheiro ao cliente
                    String sqlRetira = "UPDATE CARTEIRA SET saldo = saldo - ? WHERE id_carteira = ?";
                    PreparedStatement psRetira = conn.prepareStatement(sqlRetira);
                    psRetira.setDouble(1, totalPagar);
                    psRetira.setInt(2, idCarteira);
                    psRetira.executeUpdate();

                    // adicionar o dinheiro na carteira da loja
                    // procuramos a carteira da loja (tipoCarteiraId 2)
                    Statement stLoja = conn.createStatement();
                    ResultSet rsLoja = stLoja.executeQuery("SELECT id_carteira FROM CARTEIRA WHERE tipoCarteiraId = 2");
                    if(rsLoja.next()) {
                        int idCartLoja = rsLoja.getInt("id_carteira");
                        PreparedStatement psDeposita = conn.prepareStatement("UPDATE CARTEIRA SET saldo = saldo + ? WHERE id_carteira = ?");
                        psDeposita.setDouble(1, totalPagar);
                        psDeposita.setInt(2, idCartLoja);
                        psDeposita.executeUpdate();
                    }

                    // fecha a encomenda (muda de estado 0 para 1)
                    PreparedStatement psFecha = conn.prepareStatement("UPDATE ENCOMENDA SET estado = 1, valor_total = ? WHERE id_encomenda = ?");
                    psFecha.setDouble(1, totalPagar);
                    psFecha.setInt(2, idEnc);
                    psFecha.executeUpdate();

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