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

<!-- botões de controlo -->
<div class="bg-white p-4 rounded shadow-sm border">
    <%
        secao = request.getParameter("secao"); //utilizadores/editar_utilizador/aprovar_utilizador
        acao = request.getParameter("acao"); //remover
        id = request.getParameter("id"); //id do utilizador recebido

        // --- ações ---
        //aprovar um utilizador a usar o site
        if("aprovar_utilizador".equals(secao) && id != null){
            int idParaAprovar = Integer.parseInt(id);

            String sqlAprove = "UPDATE UTILIZADOR SET validation = 1 WHERE id_utilizador = ?";
            PreparedStatement statementAprove = conn.prepareStatement(sqlAprove);
            statementAprove.setInt(1, idParaAprovar);
            statementAprove.executeUpdate();

            out.println("<div class='alert alert-success'>Utilizador aprovado com sucesso!</div>");
            response.setHeader("Refresh", "1; URL=pagina_admin.jsp?secao=utilizadores");
        }

        if ("remover".equals(acao) && id != null) {
            int idParaApagar = Integer.parseInt(id);

            // apaga os itens das encomendas do utilizador
            String sqlItens = "DELETE FROM item_encomenda WHERE id_encomenda IN (SELECT id_encomenda FROM encomenda WHERE id_utilizador = ?)";
            PreparedStatement clearItens = conn.prepareStatement(sqlItens);
            clearItens.setInt(1, idParaApagar);
            clearItens.executeUpdate();

            // apaga as encomendas do utilizador
            String sqlEnc = "DELETE FROM encomenda WHERE id_utilizador = ?";
            PreparedStatement clearEnc = conn.prepareStatement(sqlEnc);
            clearEnc.setInt(1, idParaApagar);
            clearEnc.executeUpdate();

            // apagar os movimentos de carteira (origem ou destino)
            String sqlMov = "DELETE FROM movimento_carteira WHERE " +
                    "id_carteira_origem IN (SELECT id_carteira FROM carteira WHERE id_utilizador = ?) OR " +
                    "id_carteira_destino IN (SELECT id_carteira FROM carteira WHERE id_utilizador = ?)";
            PreparedStatement clearMov = conn.prepareStatement(sqlMov);
            clearMov.setInt(1, idParaApagar);
            clearMov.setInt(2, idParaApagar);
            clearMov.executeUpdate();

            // apaga a carteira
            String sqlCart = "DELETE FROM carteira WHERE id_utilizador = ?";
            PreparedStatement clearCart = conn.prepareStatement(sqlCart);
            clearCart.setInt(1, idParaApagar);
            clearCart.executeUpdate();

            // apaga o utilizador
            String sqlUser = "DELETE FROM UTILIZADOR WHERE id_utilizador = ?";
            PreparedStatement clearUser = conn.prepareStatement(sqlUser);
            clearUser.setInt(1, idParaApagar);
            clearUser.executeUpdate();

            out.println("<div class='alert alert-danger'>Utilizador removido!</div>");
            response.setHeader("Refresh", "1; URL=pagina_admin.jsp?secao=utilizadores");
        }

        // --- interface ---

        // secao utilizadores, apresenta a tabela com os utilizadores da bd
        if ("utilizadores".equals(secao) || secao == null) {
    %>
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="text-primary">Gestão de Utilizadores</h2>
        <a href="registo.jsp" class="btn btn-success">Novo Utilizador</a>
    </div>
    <table class="table table-hover border">
        <thead class="table-dark">
        <tr>
            <th>Nome</th>
            <th>Tipo</th>
            <th>Ações</th>
        </tr>
        </thead>
        <tbody>
        <% //vamos buscar o tipoConta de utilizador, se esta validado e o id
            Statement statement = conn.createStatement();
            String sql = "SELECT u.id_utilizador, u.username, u.validation, u.tipoContaID " +
                    "FROM utilizador u " +
                    "WHERE u.username != 'felixubershop' "; //o nome da loja não aparece

            ResultSet result = statement.executeQuery(sql);
            while (result.next()) {
                int tipoContaId = result.getInt("tipoContaId");
                String tipoUtilizador = "";

                if (tipoContaId == 1) {
                    tipoUtilizador = "Admin";
                } else if (tipoContaId == 2) {
                    tipoUtilizador = "Funcionario";
                } else {
                    tipoUtilizador = "Cliente";
                }
                int validation = result.getInt("validation");
                int idUser = result.getInt("id_utilizador");
        %>
        <tr> <!-- apresentamos o nome do utilizador na coluna nome -->
            <td><%= result.getString("username") %></td>
            <!-- tipoConta de utilizador -->
            <td><span class="badge bg-secondary"><%= tipoUtilizador %></span></td>
            <td>
                <!-- se ja esta validado, pode ser editado -->
                <% if (validation == 1) { %>
                <a href="pagina_admin.jsp?secao=editar_utilizador&id=<%= idUser %>" class="btn btn-sm btn-outline-primary">✏️</a>
                <% } else { %>
                <!-- se não esta validado -->
                <a href="pagina_admin.jsp?secao=aprovar_utilizador&id=<%= idUser %>" class="btn btn-sm btn-warning">✔️ Aprovar</a>
                <% } %>
                <!-- remover utilizador da bd -->
                <a href="pagina_admin.jsp?secao=utilizadores&acao=remover&id=<%= idUser %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Apagar utilizador?')">🗑️</a>
            </td>
        </tr>
        <%
            }
        %>
        </tbody>
    </table>
    <%
        //fim de secao utilizadores
    // secao editar_utilizadores
    } else if ("editar_utilizador".equals(secao)  && id != null) {
    %>
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
        <a href="pagina_admin.jsp?secao=utilizadores" class="btn btn-sm btn-outline-secondary">← Voltar</a>
    </div>

    <%-- invoca o formulario--%>
    <%@ include file="editar_utilizador.jsp" %>

    <%
        } else {
            out.println("<h2>Seção '" + secao + "' em construção.</h2>");
        }
    %>
</div>
