<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- segurança de login --- (Mantida)
    if (autenticado == null || tipoConta == null) {
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return;
    }
%>

<div class="bg-white p-4 rounded shadow-sm border">
    <%
        secao = request.getParameter("secao");
        acao = request.getParameter("acao");
        id = request.getParameter("id");

        // --- ação de alterar o estado ---
        if ("alternar_estado".equals(acao) && id != null) {
            int idUserEstado = Integer.parseInt(id); // id do utilizador a ativar/desativar

            // se a validação for 1 muda para 2, e vice versa
            String sqlMudaVal = "UPDATE UTILIZADOR SET validation = CASE WHEN validation = 1 THEN 2 ELSE 1 END WHERE id_utilizador = ?";
            PreparedStatement statementMudaVal = conn.prepareStatement(sqlMudaVal);
            statementMudaVal.setInt(1, idUserEstado);
            statementMudaVal.executeUpdate();

            out.println("<div class='alert alert-info text-center'>Estado do utilizador atualizado!</div>");
            response.setHeader("Refresh", "1; URL=pagina_admin.jsp?secao=utilizadores");
        }

        // --- interface ---
        if ("utilizadores".equals(secao) || secao == null) {
    %>
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h2 class="text-primary">Gestão de Utilizadores</h2>
        <a href="registo.jsp" class="btn btn-success">Novo Utilizador</a>
    </div>
    <table class="table table-hover border align-middle">
        <thead class="table-dark">
        <tr>
            <th>Nome</th>
            <th>Tipo</th>
            <th>Estado</th>
            <th class="text-center">Ações</th>
        </tr>
        </thead>
        <tbody> <!-- aqui procuramos os utilizadores do site menos a conta da loja por motivos de segurança -->
        <%
            Statement statement = conn.createStatement();
            String sql = "SELECT id_utilizador, username, validation, tipoContaID FROM utilizador WHERE username != 'felixubershop'";
            ResultSet result = statement.executeQuery(sql);

            while (result.next()) {
                int idUser = result.getInt("id_utilizador");
                int validation = result.getInt("validation");
                int tipoId = result.getInt("tipoContaID");

                String tipoStr = (tipoId == 1) ? "Admin" : (tipoId == 2) ? "Funcionario" : "Cliente";
        %>
        <tr> <!-- preenchemos a tabela e conforme a logica os botões de controlo -->
            <td><strong><%= result.getString("username") %></strong></td>
            <td><span class="badge bg-secondary"><%= tipoStr %></span></td>
            <td>
                <% if (validation == 1) { %>
                <span class="badge bg-success">Ativo</span>
                <% } else { %>
                <span class="badge bg-danger">Inativo</span>
                <% } %>
            </td>
            <td class="text-center">
                <a href="pagina_admin.jsp?secao=editar_utilizador&id=<%= idUser %>" class="btn btn-sm btn-outline-primary" title="Editar">✏️</a>

                <% if (validation == 1) { %>
                <a href="pagina_admin.jsp?secao=utilizadores&acao=alternar_estado&id=<%= idUser %>"
                   class="btn btn-sm btn-outline-warning"
                   onclick="return confirm('Deseja desativar este utilizador?')" title="Desativar">
                    🚫 Bloquear
                </a>
                <% } else { %>
                <a href="pagina_admin.jsp?secao=utilizadores&acao=alternar_estado&id=<%= idUser %>"
                   class="btn btn-sm btn-success"
                   onclick="return confirm('Deseja ativar este utilizador?')" title="Ativar">
                    ✅ Ativar
                </a>
                <% } %>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
    <%
    } else if ("editar_utilizador".equals(secao) && id != null) {
    %>
    <div class="mb-3"><a href="pagina_admin.jsp?secao=utilizadores" class="btn btn-sm btn-outline-secondary">← Voltar</a></div>
    <%@ include file="editar_utilizador.jsp" %>
    <%
        }
    %>
</div>