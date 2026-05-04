<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!-- logica dos controlos -->
<div class="bg-white p-4 rounded shadow-sm border">
    <%
        secao = request.getParameter("secao"); //utilizadores/editar_utilizadores/aprovar_utilizador
        acao = request.getParameter("acao"); //remover
        userId = request.getParameter("id"); //id do utilizador recebido nos gets

        // --- Ações ---
        if (conn != null) {
            // remover utilizador da bd
            if ("remover".equals(acao) && userId != null) {
                String sql = "DELETE FROM UTILIZADOR WHERE id_utilizador = ?";
                PreparedStatement clear = conn.prepareStatement(sql);
                clear.setInt(1, Integer.parseInt(userId));
                clear.executeUpdate();
                out.println("<div class='alert alert-danger'>Utilizador removido!</div>");
                response.setHeader("Refresh", "1; URL=pagina_admin.jsp?secao=utilizadores");
            }

            // aprovar_utilizador
            if ("aprovar_utilizador".equals(secao) && userId != null) {
                String sql = "UPDATE UTILIZADOR SET validation = 1 WHERE id_utilizador = ?";
                PreparedStatement aprove = conn.prepareStatement(sql);
                aprove.setInt(1, Integer.parseInt(userId));
                aprove.executeUpdate();
                out.println("<div class='alert alert-success'>Utilizador aprovado!</div>");
                response.setHeader("Refresh", "1; URL=pagina_admin.jsp?secao=utilizadores");
            }

            // editar, recebe os dados do formulario
            if (request.getParameter("editar") != null) {
                String idUpd = request.getParameter("id_update");
                String nomeUpd = request.getParameter("novo_nome");
                int tipoUpd = Integer.parseInt(request.getParameter("novo_tipo"));

                String sql = "UPDATE UTILIZADOR SET username=?, tipoContaId=? WHERE id_utilizador=?";
                PreparedStatement statement = conn.prepareStatement(sql);
                statement.setString(1, nomeUpd);
                statement.setInt(2, tipoUpd);
                statement.setInt(3, Integer.parseInt(idUpd));
                statement.executeUpdate();
                out.println("<div class='alert alert-success'>Dados atualizados!</div>");
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
                <a href="pagina_admin.jsp?secao=editar_utilizadores&id=<%= idUser %>" class="btn btn-sm btn-outline-primary">✏️</a>
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
    } //fim de secao utilizadores
    // secao editar_utilizadores
    else if ("editar_utilizadores".equals(secao)) {
        String sql = "SELECT * FROM UTILIZADOR WHERE id_utilizador = ?";
        PreparedStatement statement = conn.prepareStatement(sql);
        statement.setInt(1, Integer.parseInt(userId)); //id de utilizador recebido do botão de editar da tabela
        ResultSet result = statement.executeQuery();
        if(result.next()) {
    %>
    <h2 class="text-primary mb-4">Editar Utilizador</h2>
    <form action="pagina_admin.jsp?secao=utilizadores" method="POST" class="col-md-6">
        <!-- guarda o id do utilizador a ser alterado -->
        <input type="hidden" name="id_update" value="<%= userId %>">
        <div class="mb-3">
            <label class="form-label fw-bold">Nome de Utilizador</label>
            <input type="text" name="novo_nome" class="form-control" value="<%= result.getString("username") %>" required>
        </div>
        <div class="mb-3">
            <label class="form-label fw-bold">Tipo de Conta</label>
            <select name="novo_tipo" class="form-select">
                <!-- apresenta o tipo de utilizador atual como primeira opção da lista -->
                <option value="1" <%= result.getInt("tipoContaId") == 1 ? "selected" : "" %>>Administrador</option>
                <option value="2" <%= result.getInt("tipoContaId") == 2 ? "selected" : "" %>>Funcionário</option>
                <option value="3" <%= result.getInt("tipoContaId") == 3 ? "selected" : "" %>>Cliente</option>
            </select>
        </div>
        <!-- envia os dados do formulario -->
        <button type="submit" name="editar" class="btn btn-primary">Gravar Alterações</button>
        <a href="pagina_admin.jsp?secao=utilizadores" class="btn btn-light border">Cancelar</a>
    </form>
    <%
            }
        } else {
            out.println("<h3 class='text-muted'>A secção '" + secao + "' está em desenvolvimento.</h3>");
        }
    %>
    </div>
</div>