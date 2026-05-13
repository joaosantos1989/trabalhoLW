<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    // --- segurança de Login ---
    Object autenticado = session.getAttribute("autenticado");
    Object tipoConta = session.getAttribute("TipoConta");

    if (autenticado == null || tipoConta == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // pagina de utilizador a voltar
    int tipoLogado = (int)tipoConta;
    String pagVolta = (tipoLogado == 1) ? "pagina_admin.jsp?secao=encomendas" : (tipoLogado == 2) ? "pagina_funcionario.jsp?secao=encomendas" : "pagina_cliente.jsp?secao=encomendas";

    String idEncRecebido = request.getParameter("id_enc");

    if (idEncRecebido != null && conn != null) {
        int idEnc = Integer.parseInt(idEncRecebido);

        // --- procura dados da encomenda ---
        // precisamos do id do cliente e do valor para devolver
        String sqlEnc = "SELECT id_utilizador, valor_total, estado FROM ENCOMENDA WHERE id_encomenda = ?";
        PreparedStatement statementEnc = conn.prepareStatement(sqlEnc);
        statementEnc.setInt(1, idEnc);
        ResultSet resultEnc = statementEnc.executeQuery();

        if (resultEnc.next()) {
            int idCliente = resultEnc.getInt("id_utilizador");
            double total = resultEnc.getDouble("valor_total");
            int estadoAtual = resultEnc.getInt("estado");

            // só cancela se estiver paga (estado 1)
            if (estadoAtual == 1) {

                // devolve dinheiro ao cliente
                PreparedStatement psCli = conn.prepareStatement("UPDATE CARTEIRA SET saldo = saldo + ? WHERE id_utilizador = ?");
                psCli.setDouble(1, total);
                psCli.setInt(2, idCliente);
                psCli.executeUpdate();

                // retira dinheiro à Loja (tipoCarteiraId = 2)
                PreparedStatement psLoja = conn.prepareStatement("UPDATE CARTEIRA SET saldo = saldo - ? WHERE tipoCarteiraId = 2");
                psLoja.setDouble(1, total);
                psLoja.executeUpdate();

                // regista o movimento (id 4 = encomenda cancelada)
                // vamos buscar os ids das carteiras para o registo
                int idLoja = 0;
                int idCartCli = 0;

                ResultSet resultLoja = conn.createStatement().executeQuery("SELECT id_carteira FROM CARTEIRA WHERE tipoCarteiraId = 2");
                if(resultLoja.next()) idLoja = resultLoja.getInt(1);

                ResultSet resultCliente = conn.createStatement().executeQuery("SELECT id_carteira FROM CARTEIRA WHERE id_utilizador = " + idCliente);
                if(resultCliente.next()) idCartCli = resultCliente.getInt(1);

                // no movimento de cancelamento, origem é a loja, destino é o cliente
                String sqlReg = "INSERT INTO movimento_carteira (data_hora, valor, tipoOperacaoId, id_carteira_origem, id_carteira_destino) VALUES (NOW(), ?, 4, ?, ?)";
                PreparedStatement statementReg = conn.prepareStatement(sqlReg);
                statementReg.setDouble(1, total);
                statementReg.setInt(2, idLoja);       // sai da loja
                statementReg.setInt(3, idCartCli);    // entra no cliente
                statementReg.executeUpdate();

                // muda o estado da encomenda para 3 (cancelada)
                PreparedStatement statementFim = conn.prepareStatement("UPDATE ENCOMENDA SET estado = 3 WHERE id_encomenda = ?");
                statementFim.setInt(1, idEnc);
                statementFim.executeUpdate();

                response.sendRedirect(pagVolta + "&msg=cancelada_ok");
                return;
            }
        }
    }
    response.sendRedirect(pagVolta + "&msg=erro");
%>