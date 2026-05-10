<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!-- logica dos botões de controlo -->
<div class="bg-white p-4 rounded shadow-sm border">
    <%
        secao = request.getParameter("secao"); //utilizadores/editar_utilizador/aprovar_utilizador
        acao = request.getParameter("acao"); //remover
        id = request.getParameter("id"); //id do utilizador recebido nos gets

        // --- Ações ---
        if (conn != null) {
            // remover utilizador da bd
            if ("remover".equals(acao) && id != null) {
                String sql = "DELETE FROM UTILIZADOR WHERE id_utilizador = ?";
                PreparedStatement clear = conn.prepareStatement(sql);
                clear.setInt(1, Integer.parseInt(id));
                clear.executeUpdate();
                out.println("<div class='alert alert-danger'>Utilizador removido!</div>");
                response.setHeader("Refresh", "1; URL=pagina_admin.jsp?secao=utilizadores");
            }

            // aprovar_utilizador
            if ("aprovar_utilizador".equals(secao) && id != null) {
                String sql = "UPDATE UTILIZADOR SET validation = 1 WHERE id_utilizador = ?";
                PreparedStatement aprove = conn.prepareStatement(sql);
                aprove.setInt(1, Integer.parseInt(id));
                aprove.executeUpdate();
                out.println("<div class='alert alert-success'>Utilizador aprovado!</div>");
                response.setHeader("Refresh", "1; URL=pagina_admin.jsp?secao=utilizadores");
            }
        }

        // --- Interface ---

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
        <% //vamos buscar o tipo de utilizador, se esta validado e o id
            Statement statement = conn.createStatement();
            String sql = "SELECT * FROM UTILIZADOR";
            ResultSet result = statement.executeQuery(sql);
            while (result.next()) {
                int tipoContaId = result.getInt("tipoContaId");
                String tipoUser = "";

                if (tipoContaId == 1) {
                    tipoUser = "Admin";
                } else if (tipoContaId == 2) {
                    tipoUser = "Funcionario";
                } else {
                    tipoUser = "Cliente";
                }
                int validation = result.getInt("validation");
                int idUser = result.getInt("id_utilizador");
        %>
        <tr> <!-- apresentamos o nome do utilizador na coluna nome -->
            <td><%= result.getString("username") %></td>
            <!-- badge = etiqueta arredondada, apresenta o tipo de utilizador na coluna tipo -->
            <td><span class="badge bg-secondary"><%= tipoUser %></span></td>
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
            } //fim do while
        %>
        </tbody>
    </table>
    <%
        //fim de secao utilizadores
    // secao editar_utilizadores
    } else if ("editar_utilizador".equals(secao)  && id != null) {
    %>
    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-2">
        <a href="pagina_admin.jsp?secao=utilizadores" class="btn btn-sm btn-outline-secondary">← Voltar à lista</a>
    </div>

    <%-- invoca o formulario--%>
    <%@ include file="editar_utilizador.jsp" %>

    <%
        } else {
            out.println("<h2>Seção '" + secao + "' em construção.</h2>");
        }
    %>
</div>
