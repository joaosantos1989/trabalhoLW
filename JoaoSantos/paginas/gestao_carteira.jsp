<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    Object sessaoID = session.getAttribute("idUtilizador");
    Object sessaoTipo = session.getAttribute("TipoConta");

    // Só avança se estiver logado
    if (sessaoID != null && sessaoTipo != null) {
        int idLogado = (int) sessaoID;
        int tipoUser = (int) sessaoTipo;

        // id do utilizador recebido
        String idUserRecebido = request.getParameter("id");
        String idUserGerido;//user a ser gerido

        // se o id for recebido significa que esta a ser gerido por admin ou funcionario
        if (idUserRecebido != null) {
            idUserGerido = idUserRecebido;
        } else {
            // se não for recebido significa que é o cliente a gerir o seu saldo
            idUserGerido = session.getAttribute("idUtilizador").toString();
        }

        // volta para a pagina do utilizador a gerir a carteira
        String pagAnterior = (tipoUser == 1) ? "pagina_admin.jsp?secao=carteira"
                            : (tipoUser == 2) ? "pagina_funcionario.jsp?secao=carteira"
                            : "pagina_cliente.jsp?secao=inicio";

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            double valor = Double.parseDouble(request.getParameter("valor"));
            String operacao = request.getParameter("operacao");
            double valorFinal = ("retirar".equals(operacao)) ? -valor : valor;

            // Update Saldo
            String sqlUpdate = "UPDATE carteira SET saldo = saldo + ? WHERE id_utilizador = ?";
            PreparedStatement ps1 = conn.prepareStatement(sqlUpdate);
            ps1.setDouble(1, valorFinal);
            ps1.setInt(2, Integer.parseInt(idUserGerido));
            ps1.executeUpdate();

            // registo do movimento
            String sqlReg = "INSERT INTO movimento_carteira (data_hora, valor, tipoOperacaoId, " +
                            "id_carteira_origem, id_carteira_destino) VALUES (NOW(), ?, ?, ?, ?)";
            PreparedStatement statementReg = conn.prepareStatement(sqlReg);
            statementReg.setDouble(1, valor);
            statementReg.setInt(2, ("adicionar".equals(operacao) ? 2 : 3));
            statementReg.setInt(3, idLogado);
            statementReg.setInt(4, Integer.parseInt(idUserGerido));
            statementReg.executeUpdate();

            response.sendRedirect(pagAnterior + "&msg=saldo_ok");
            return;
        }

        // procuramos o nome e o saldo do utilziador
        String sqlSelect = "SELECT u.username, c.saldo FROM utilizador u, carteira c " +
                            "WHERE u.id_utilizador = c.id_utilizador AND u.id_utilizador = ?";
        PreparedStatement statementSelect = conn.prepareStatement(sqlSelect);
        statementSelect.setInt(1, Integer.parseInt(idUserGerido));
        ResultSet resultSelect = statementSelect.executeQuery();

        if (resultSelect.next()) {
%>

<div class="row justify-content-center mt-3">
    <div class="col-md-5">
        <div class="card p-4 shadow-sm border-0">
            <h4 class="text-center">Gerir: <strong><%= resultSelect.getString("username") %></strong></h4>

            <div class="alert alert-info text-center my-3">
                Saldo Atual: <strong><%= resultSelect.getDouble("saldo") %>€</strong>
            </div>

            <form method="POST">
                <div class="mb-3">
                    <label class="form-label small fw-bold">Valor (€):</label>
                    <input type="number" name="valor" step="0.01" min="0.01" class="form-control" required placeholder="0.00">
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-bold">Operação:</label>
                    <select name="operacao" class="form-select">
                        <option value="adicionar">➕ Adicionar Saldo</option>
                        <option value="retirar">➖ Retirar Saldo</option>
                    </select>
                </div>

                <button type="submit" class="btn btn-primary w-100">Confirmar Alteração</button>
                <a href="<%= pagAnterior %>" class="btn btn-outline-secondary w-100 mt-2">← Voltar</a>
            </form>
        </div>
    </div>
</div>

<%
        }
    }
%>