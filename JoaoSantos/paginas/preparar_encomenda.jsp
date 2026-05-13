<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<%
    // --- 1. Segurança de Login ---
    Object autenticado = session.getAttribute("autenticado");
    Object tipoConta = session.getAttribute("TipoConta");

    if (autenticado == null || tipoConta == null) {
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return;
    }

    // --- 2. Obter dados da Sessão ---
    int idLogado = (int) session.getAttribute("idUtilizador");
    int idCartLogada = (int) session.getAttribute("idCarteira");
    String idEncomenda = request.getParameter("id_enc");

    if (idEncomenda != null && conn != null) {
        try {
            int idEnc = Integer.parseInt(idEncomenda);

            // --- 3. Calcular o valor total real da encomenda ---
            // Fazemos a soma diretamente da base de dados para evitar manipulações
            String sqlValor = "SELECT SUM(preco_unitario * quantidade) AS total_encomenda FROM ITEM_ENCOMENDA WHERE id_encomenda = ?";
            PreparedStatement psValor = conn.prepareStatement(sqlValor);
            psValor.setInt(1, idEnc);
            ResultSet rsValor = psValor.executeQuery();

            double totalEnc = 0;
            if (rsValor.next()) {
                totalEnc = rsValor.getDouble("total_encomenda");
            }
            rsValor.close();
            psValor.close();

            // --- 4. Verificar o saldo do cliente antes de cobrar ---
            String sqlSaldo = "SELECT saldo FROM CARTEIRA WHERE id_carteira = ?";
            PreparedStatement psSaldo = conn.prepareStatement(sqlSaldo);
            psSaldo.setInt(1, idCartLogada);
            ResultSet rsSaldo = psSaldo.executeQuery();

            if (rsSaldo.next()) {
                double saldoAtual = rsSaldo.getDouble("saldo");

                if (saldoAtual >= totalEnc && totalEnc > 0) {
                    // --- SUCESSO: REALIZAR O PAGAMENTO IMEDIATO ---

                    // A) Retirar dinheiro ao Cliente
                    String sqlRetira = "UPDATE CARTEIRA SET saldo = saldo - ? WHERE id_carteira = ?";
                    PreparedStatement psRetira = conn.prepareStatement(sqlRetira);
                    psRetira.setDouble(1, totalEnc);
                    psRetira.setInt(2, idCartLogada);
                    psRetira.executeUpdate();

                    // B) Depositar na conta da Loja (tipoCarteiraId = 2)
                    String sqlLoja = "UPDATE CARTEIRA SET saldo = saldo + ? WHERE tipoCarteiraId = 2";
                    PreparedStatement psLoja = conn.prepareStatement(sqlLoja);
                    psLoja.setDouble(1, totalEnc);
                    psLoja.executeUpdate();

                    // C) Obter ID da carteira da loja para o Histórico de Movimentos
                    int idCartLoja = 0;
                    Statement stL = conn.createStatement();
                    ResultSet rsL = stL.executeQuery("SELECT id_carteira FROM CARTEIRA WHERE tipoCarteiraId = 2");
                    if (rsL.next()) {
                        idCartLoja = rsL.getInt("id_carteira");
                    }

                    // D) Registar Movimento (Tipo 3 = Encomenda Paga)
                    String sqlReg = "INSERT INTO movimento_carteira (data_hora, valor, tipoOperacaoId, id_carteira_origem, id_carteira_destino) " +
                            "VALUES (NOW(), ?, 3, ?, ?)";
                    PreparedStatement psReg = conn.prepareStatement(sqlReg);
                    psReg.setDouble(1, totalEnc);
                    psReg.setInt(2, idCartLogada); // Origem: Cliente
                    psReg.setInt(3, idCartLoja);   // Destino: Loja
                    psReg.executeUpdate();

                    // E) Finalizar Encomenda (Estado 1 = Paga/Pendente de Validação)
                    String sqlUpdateEnc = "UPDATE ENCOMENDA SET valor_total = ?, estado = 1 WHERE id_encomenda = ?";
                    PreparedStatement psUpd = conn.prepareStatement(sqlUpdateEnc);
                    psUpd.setDouble(1, totalEnc);
                    psUpd.setInt(2, idEnc);
                    psUpd.executeUpdate();

                    // Redireciona com SUCESSO
                    response.sendRedirect("carrinho.jsp?msg=pendente");
                    return;

                } else {
                    // ERRO: Saldo insuficiente
                    response.sendRedirect("carrinho.jsp?msg=erro_saldo");
                    return;
                }
            }
            rsSaldo.close();
            psSaldo.close();

        } catch (Exception e) {
            // Em caso de erro técnico, volta para o carrinho
            out.println("Erro ao processar: " + e.getMessage());
        }
    } else {
        response.sendRedirect("carrinho.jsp");
    }
%>