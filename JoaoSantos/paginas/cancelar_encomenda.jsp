<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    // --- 1. Segurança de Login ---
    Object autenticado = session.getAttribute("autenticado");
    Object tipoConta = session.getAttribute("TipoConta");

    if (autenticado == null || tipoConta == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Definir para onde voltar (Admin ou Funcionário)
    int tipoLogado = (int)tipoConta;
    String pagVolta = (tipoLogado == 1) ? "pagina_admin.jsp?secao=encomendas" : "pagina_funcionario.jsp?secao=encomendas";

    String idEncRecebido = request.getParameter("id_enc");

    if (idEncRecebido != null && conn != null) {
        int idEnc = Integer.parseInt(idEncRecebido);

        // --- 2. Procurar dados da encomenda ---
        // Precisamos do ID do cliente e do valor para devolver
        String sqlEnc = "SELECT id_utilizador, valor_total, estado FROM ENCOMENDA WHERE id_encomenda = ?";
        PreparedStatement psEnc = conn.prepareStatement(sqlEnc);
        psEnc.setInt(1, idEnc);
        ResultSet rsEnc = psEnc.executeQuery();

        if (rsEnc.next()) {
            int idCliente = rsEnc.getInt("id_utilizador");
            double total = rsEnc.getDouble("valor_total");
            int estadoAtual = rsEnc.getInt("estado");

            // SÓ CANCELA SE ESTIVER PAGA (Estado 1)
            if (estadoAtual == 1) {

                // A) Devolve dinheiro ao cliente
                PreparedStatement psCli = conn.prepareStatement("UPDATE CARTEIRA SET saldo = saldo + ? WHERE id_utilizador = ?");
                psCli.setDouble(1, total);
                psCli.setInt(2, idCliente);
                psCli.executeUpdate();

                // B) Retira dinheiro à Loja (tipoCarteiraId = 2)
                PreparedStatement psLoja = conn.prepareStatement("UPDATE CARTEIRA SET saldo = saldo - ? WHERE tipoCarteiraId = 2");
                psLoja.setDouble(1, total);
                psLoja.executeUpdate();

                // C) REGISTAR O MOVIMENTO (ID 4 = Encomenda Cancelada)
                // Vamos buscar os IDs das carteiras para o registo
                int idLoja = 0;
                int idCartCli = 0;

                ResultSet rsL = conn.createStatement().executeQuery("SELECT id_carteira FROM CARTEIRA WHERE tipoCarteiraId = 2");
                if(rsL.next()) idLoja = rsL.getInt(1);

                ResultSet rsC = conn.createStatement().executeQuery("SELECT id_carteira FROM CARTEIRA WHERE id_utilizador = " + idCliente);
                if(rsC.next()) idCartCli = rsC.getInt(1);

                // No movimento de cancelamento: Origem é a LOJA, Destino é o CLIENTE
                String sqlReg = "INSERT INTO movimento_carteira (data_hora, valor, tipoOperacaoId, id_carteira_origem, id_carteira_destino) VALUES (NOW(), ?, 4, ?, ?)";
                PreparedStatement psReg = conn.prepareStatement(sqlReg);
                psReg.setDouble(1, total);
                psReg.setInt(2, idLoja);       // Sai da loja
                psReg.setInt(3, idCartCli);    // Entra no cliente
                psReg.executeUpdate();

                // D) Muda o estado da encomenda para 3 (Cancelada)
                PreparedStatement psFim = conn.prepareStatement("UPDATE ENCOMENDA SET estado = 3 WHERE id_encomenda = ?");
                psFim.setInt(1, idEnc);
                psFim.executeUpdate();

                response.sendRedirect(pagVolta + "&msg=cancelada_ok");
                return;
            }
        }
    }
    response.sendRedirect(pagVolta + "&msg=erro");
%>