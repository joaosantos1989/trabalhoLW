<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    String idUser = request.getParameter("id");

    if (request.getMethod().equalsIgnoreCase("POST")) {
        double valor = Double.parseDouble(request.getParameter("valor"));
        String operacao = request.getParameter("operacao"); // adicionar/retirar

        // se for para retirar saldo, o valor fica negativo para a conta
        double valorFinal = (operacao.equals("retirar")) ? -valor : valor;

        // atualiza o saldo na tabela CARTEIRA
        String sqlUpdate = "UPDATE carteira SET saldo = saldo + ? WHERE id_utilizador = ?";
        PreparedStatement statementUpdate = conn.prepareStatement(sqlUpdate);
        statementUpdate.setDouble(1, valorFinal);
        statementUpdate.setInt(2, Integer.parseInt(idUser));
        statementUpdate.executeUpdate();

        // regista o movimento
        String sqlInsert = "INSERT INTO movimento_carteira (data_hora, valor, tipoOperacaoId, id_carteira_origem, id_carteira_destino) VALUES (NOW(), ?, ?, ?, ?)";
        PreparedStatement statementInsert = conn.prepareStatement(sqlInsert);
        statementInsert.setDouble(1, valor);
        statementInsert.setInt(2, (operacao.equals("adicionar") ? 2 : 3)); // 2=Paga/Adicionado, 3=Cancelado/Retirado
        statementInsert.setInt(3, (int)session.getAttribute("idUtilizador")); // id do utilizador origem
        statementInsert.setInt(4, Integer.parseInt(idUser)); // id do utilizador destino
        statementInsert.executeUpdate();

        response.sendRedirect("pagina_admin.jsp?secao=carteira&msg=saldo_ok");
    }

    // procuramos o nome do cliente para mostrar no título
    PreparedStatement statementNome = conn.prepareStatement("SELECT username FROM utilizador WHERE id_utilizador = ?");
    statementNome.setInt(1, Integer.parseInt(idUser));
    ResultSet resultNome = statementNome.executeQuery();
    if (resultNome.next()) {
%>


<div class="row justify-content-center mt-4">
    <div class="col-md-5">
        <div class="card shadow-sm border p-4 bg-white">
            <h3 class="text-center fw-bold mb-4">Gerir Saldo: <%= resultNome.getString("username") %></h3>

            <!-- formulario -->
            <form method="POST">
                <div class="mb-3">
                    <label class="form-label small fw-bold">Valor (€):</label>
                    <input type="number" name="valor" step="0.01" class="form-control form-control-lg" required>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-bold">Operação:</label>
                    <select name="operacao" class="form-select form-select-lg">
                        <option value="adicionar">➕ Adicionar Saldo</option>
                        <option value="retirar">➖ Retirar Saldo</option>
                    </select>
                </div>

                <button type="submit" class="btn btn-primary w-100 btn-lg">Confirmar Alteração</button>
                <a href="pagina_admin.jsp?secao=carteira" class="btn btn-light w-100 mt-2 border">Voltar</a>
            </form>
        </div>
    </div>
</div>

<% } %>