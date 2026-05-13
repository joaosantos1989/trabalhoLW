<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<%
    // --- segurança de Login ---
    Object autenticado = session.getAttribute("autenticado");
    Object tipoConta = session.getAttribute("TipoConta");

    if (autenticado == null || tipoConta == null) {
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return;
    }

    // --- dados da sessão ---
    int idLogado = (int) session.getAttribute("idUtilizador");
    int idCartLogada = (int) session.getAttribute("idCarteira");
    String idEncomenda = request.getParameter("id_enc");

    if (idEncomenda != null && conn != null) {
        int idEnc = Integer.parseInt(idEncomenda);

        // --- procura e calcula o valor total real da encomenda ---
        String sqlValor = "SELECT SUM(preco_unitario * quantidade) AS total_encomenda FROM ITEM_ENCOMENDA WHERE id_encomenda = ?";
        PreparedStatement statementValor = conn.prepareStatement(sqlValor);
        statementValor.setInt(1, idEnc);
        ResultSet resultValor = statementValor.executeQuery();

        double totalEnc = 0;
        if (resultValor.next()) { //se houver encomenda guarda o valor
            totalEnc = resultValor.getDouble("total_encomenda");
        }
        resultValor.close();
        statementValor.close();

        // --- verifica o saldo do cliente antes de cobrar ---
        String sqlSaldo = "SELECT saldo FROM CARTEIRA WHERE id_carteira = ?";
        PreparedStatement statementSaldo = conn.prepareStatement(sqlSaldo);
        statementSaldo.setInt(1, idCartLogada);
        ResultSet resultSaldo = statementSaldo.executeQuery();

        if (resultSaldo.next()) {
            double saldoAtual = resultSaldo.getDouble("saldo");

            if (saldoAtual >= totalEnc && totalEnc > 0) { //se o saldo for maior ou igual que a encomenda
                // pagamento

                // retira dinheiro ao cliente
                String sqlRetira = "UPDATE CARTEIRA SET saldo = saldo - ? WHERE id_carteira = ?";
                PreparedStatement statementRetira = conn.prepareStatement(sqlRetira);
                statementRetira.setDouble(1, totalEnc);
                statementRetira.setInt(2, idCartLogada);
                statementRetira.executeUpdate();

                // deposita na conta da loja (tipoCarteiraId = 2)
                String sqlLoja = "UPDATE CARTEIRA SET saldo = saldo + ? WHERE tipoCarteiraId = 2";
                PreparedStatement statementLoja = conn.prepareStatement(sqlLoja);
                statementLoja.setDouble(1, totalEnc);
                statementLoja.executeUpdate();

                // obtem o id da carteira da loja para o histórico de movimentos
                int idCartLoja = 0;
                String sql = "SELECT id_carteira FROM CARTEIRA WHERE tipoCarteiraId = 2";
                Statement statmentLoja = conn.createStatement();
                ResultSet resultLoja = statmentLoja.executeQuery(sql);

                if (resultLoja.next()) {
                    idCartLoja = resultLoja.getInt("id_carteira");
                }

                // regista o movimento (Tipo 3 = Encomenda Paga)
                String sqlReg = "INSERT INTO movimento_carteira (data_hora, valor, tipoOperacaoId, id_carteira_origem, id_carteira_destino) " +
                        "VALUES (NOW(), ?, 3, ?, ?)";
                PreparedStatement statmentReg = conn.prepareStatement(sqlReg);
                statmentReg.setDouble(1, totalEnc);
                statmentReg.setInt(2, idCartLogada); // origem, cliente
                statmentReg.setInt(3, idCartLoja);   // destino, loja
                statmentReg.executeUpdate();

                // finaliza encomenda (estado 1 = Paga/Pendente de Validação)
                String sqlUpdateEnc = "UPDATE ENCOMENDA SET valor_total = ?, estado = 1 WHERE id_encomenda = ?";
                PreparedStatement stamentUpdate = conn.prepareStatement(sqlUpdateEnc);
                stamentUpdate.setDouble(1, totalEnc);
                stamentUpdate.setInt(2, idEnc);
                stamentUpdate.executeUpdate();

                // redireciona com sucesso
                response.sendRedirect("carrinho.jsp?msg=pendente");
                return;

            } else {
                // saldo insuficiente
                response.sendRedirect("carrinho.jsp?msg=erro_saldo");
                return;
            }
        }
        resultSaldo.close();
        statementSaldo.close();

    } else {
        response.sendRedirect("carrinho.jsp");
    }
%>