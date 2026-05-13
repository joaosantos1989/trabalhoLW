<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- segurança de login ---
    if (autenticado == null || tipoConta == null) {
        // expulsa para o login
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return; // Interrompe a página
    }
%>

<%
    // dados da sessão
    int idLogado = (int) session.getAttribute("idUtilizador");
    int tipoLogado = (int) tipoConta;
    int idCartLogada = (int) session.getAttribute("idCarteira");

    // id recebidos do utilizador a gerir
    String idUserGerir = request.getParameter("id");
    String idCartGerir = request.getParameter("id_cart");

    // se não foi recebido nenhum id, usa o proprio porque é o cliente a gerir a sua carteira
    if (idUserGerir == null) {
        idUserGerir = String.valueOf(idLogado);
    }

    // procuramos o id da carteira
    if (idCartGerir == null) {
        String sqlProcura = "SELECT id_carteira FROM carteira WHERE id_utilizador = ?";
        PreparedStatement statementProcura = conn.prepareStatement(sqlProcura);
        statementProcura.setInt(1, Integer.parseInt(idUserGerir.trim()));
        ResultSet resultProcura = statementProcura.executeQuery();

        if (resultProcura.next()) {
            idCartGerir = String.valueOf(resultProcura.getInt("id_carteira"));
        }
    }

    // volta para a pagina do utilizador a gerir a carteira
    String pagVolta = "";
    if (tipoLogado == 1) {
        pagVolta = "pagina_admin.jsp?secao=carteira";
    } else if (tipoLogado == 2){
        pagVolta = "pagina_funcionario.jsp?secao=carteira";
    }
    else {
        pagVolta = "pagina_cliente.jsp?secao=carteira";
    }

    // formulario
    if ("POST".equalsIgnoreCase(request.getMethod())) {

        double valor = Double.parseDouble(request.getParameter("valor"));
        String operacao = request.getParameter("operacao");
        double valorFinal = 0;

        if (operacao.equals("retirar")) {
            valorFinal = -valor; // transforma em negativo para subtrair
        } else {
            valorFinal = valor;  // fica positivo para somar
        }

        // --- autaliza o saldo ---
        String sqlUpdate = "UPDATE carteira SET saldo = saldo + ? WHERE id_utilizador = ?";
        PreparedStatement adicionaSaldo = conn.prepareStatement(sqlUpdate);
        adicionaSaldo.setDouble(1, valorFinal);
        adicionaSaldo.setInt(2, Integer.parseInt(idUserGerir));
        adicionaSaldo.executeUpdate();

        // --- regista o movimento ---
        String sqlReg = "INSERT INTO movimento_carteira (data_hora, valor, tipoOperacaoId, id_carteira_origem, id_carteira_destino) VALUES (NOW(), ?, ?, ?, ?)";
        PreparedStatement registaMov = conn.prepareStatement(sqlReg);
        registaMov.setDouble(1, valor);

        if (operacao.equals("adicionar")) {
            registaMov.setInt(2, 1); // deposito
        } else {
            registaMov.setInt(2, 2); // retirar
        }

        // se o Admin/Loja não tiver carteira (idCartLogada == 0),
        // usamos a própria carteira que está a receber o dinheiro como origem.
        int origemFinal = idCartLogada;
        if (origemFinal == 0) {
            origemFinal = Integer.parseInt(idCartGerir.trim());
        }

        // USAR IDs DE CARTEIRAS
        registaMov.setInt(3, origemFinal); // Origem: ID da carteira de quem está logado
        registaMov.setInt(4, Integer.parseInt(idCartGerir.trim())); // Destino: ID da carteira gerida
        registaMov.executeUpdate();

        // Enviar de volta com mensagem de sucesso
        response.sendRedirect(pagVolta + "&msg=saldo_ok");
        return;
    }

    // procura o nome e o saldo atual para mostrar no ecrã
    String sqlDados = "SELECT u.username, c.saldo FROM utilizador u, carteira c " +
            "WHERE u.id_utilizador = c.id_utilizador AND u.id_utilizador = ?";
    PreparedStatement saldoAtual = conn.prepareStatement(sqlDados);
    saldoAtual.setInt(1, Integer.parseInt(idUserGerir));
    ResultSet resultAtual = saldoAtual.executeQuery();

    if (resultAtual.next()) {
%>

<!-- interface de operações de saldo -->
<div class="row justify-content-center mt-3">
    <div class="col-md-5 card p-4 shadow-sm">
        <h4 class="text-center">Gerir: <strong><%= resultAtual.getString("username") %></strong></h4>
        <h2 class="text-center text-success my-3"><%= resultAtual.getDouble("saldo") %>€</h2>

        <form method="POST">
            <div class="mb-3">
                <label>Valor (€):</label>
                <input type="number" name="valor" step="0.01" min="0.01" class="form-control" required>
            </div>

            <div class="mb-3">
                <label>Operação:</label>
                <select name="operacao" class="form-select">
                    <option value="adicionar">➕ Adicionar Saldo</option>
                    <option value="retirar">➖ Retirar Saldo</option>
                </select>
            </div>

            <button type="submit" class="btn btn-primary w-100">Confirmar Alteração</button>
            <a href="<%= pagVolta %>" class="btn btn-link w-100 mt-2">← Voltar</a>
        </form>
    </div>
</div>

<%
    }
%>