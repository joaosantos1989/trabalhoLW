<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    // --- segurança de login ---
    Object autenticado = session.getAttribute("autenticado");
    Object tipoConta = session.getAttribute("TipoConta");

    if (autenticado == null || tipoConta == null) {
        // expulsa para o login
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return; // Interrompe a página
    }
%>

<%
    String idEncRecebido = request.getParameter("id_enc"); //recebe o id da encomenda
    if (idEncRecebido != null && conn != null) {
        int idEnc = Integer.parseInt(idEncRecebido);

        // descobre quem é o cliente desta encomenda e qual o valor total
        String sqlEnc = "SELECT id_utilizador, valor_total FROM ENCOMENDA WHERE id_encomenda = ?";
        PreparedStatement statementEnc = conn.prepareStatement(sqlEnc);
        statementEnc.setInt(1, idEnc);
        ResultSet resultEnc = statementEnc.executeQuery();

        if (resultEnc.next()) {
            int idCliente = resultEnc.getInt("id_utilizador");
            double total = resultEnc.getDouble("valor_total");

            // verifica saldo da carteira do cliente 
            String sqlSaldo = "SELECT id_carteira, saldo FROM CARTEIRA WHERE id_utilizador = ?";
            PreparedStatement statementSaldo = conn.prepareStatement(sqlSaldo);
            statementSaldo.setInt(1, idCliente);
            ResultSet resultSaldo = statementSaldo.executeQuery();

            if (resultSaldo.next()) {
                double saldoCli = resultSaldo.getDouble("saldo"); //saldo do cliente
                int idCartCli = resultSaldo.getInt("id_carteira"); //carteira do cliente

                if (saldoCli >= total) { //se o saldo do cliente é igual ou maior que o valor total da encomenda
                    // tira dinheiro ao cliente
                    String sqlRetira = "UPDATE CARTEIRA SET saldo = saldo - ? WHERE id_carteira = ?";
                    PreparedStatement statementRetira = conn.prepareStatement(sqlRetira);
                    statementRetira.setDouble(1, total);
                    statementRetira.setInt(2, idCartCli);
                    statementRetira.executeUpdate();

                    // deposita na carteira da Loja (tipoCarteiraId = 2)
                    String sqlDeposita = "UPDATE CARTEIRA SET saldo = saldo + ? WHERE tipoCarteiraId = 2";
                    PreparedStatement statementDeposita = conn.prepareStatement(sqlDeposita);
                    statementDeposita.setDouble(1, total);
                    statementDeposita.executeUpdate();

                    //seleciona o id_carteira da loja
                    String sqlLoja = "SELECT id_carteira FROM CARTEIRA WHERE tipoCarteiraId = 2";
                    PreparedStatement statementLoja = conn.prepareStatement(sqlLoja);
                    ResultSet resultLoja = statementLoja.executeQuery();
                    int idLoja = 0;
                    if (resultLoja.next()) {
                        idLoja = resultLoja.getInt("id_carteira");
                    }

                    // regista o pagamento na tabela de movimentos
                    String sqlReg = "INSERT INTO movimento_carteira (data_hora, valor, tipoOperacaoId, id_carteira_origem, id_carteira_destino) " +
                            "VALUES (NOW(), ?, 3, ?, ?)"; // O '3' aqui indica "pagar encomenda"

                    PreparedStatement statementReg = conn.prepareStatement(sqlReg);
                    statementReg.setDouble(1, total);           // O valor total da encomenda que foi validada
                    statementReg.setInt(2, idCartCli);          // ID da carteira do CLIENTE (Origem)
                    statementReg.setInt(3, idLoja );         // ID da carteira da LOJA (Destino)

                    statementReg.executeUpdate();

                    // fecha a encomenda (Estado 2 = Paga e Validada)
                    String sqlValida = "UPDATE ENCOMENDA SET estado = 2 WHERE id_encomenda = ?";
                    PreparedStatement statementValida = conn.prepareStatement(sqlValida);
                    statementValida.setInt(1, idEnc);
                    statementValida.executeUpdate();


                    // (1 = Admin, 2 = Funcionário)
                    int tipoContaId = (int)tipoConta;

                    if (tipoContaId == 1) {

                        // volta para a página de admin
                        response.sendRedirect("pagina_admin.jsp?secao=encomendas&msg=sucesso");
                    } else {
                        // volta para a página de Funcionário
                        response.sendRedirect("pagina_funcionario.jsp?secao=encomendas&msg=sucesso");
                    }
                }
            }
        }
    }
%>