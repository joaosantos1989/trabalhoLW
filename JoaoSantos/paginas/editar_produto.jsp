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
    String idProd = request.getParameter("id");

    if (request.getMethod().equalsIgnoreCase("POST")) {
        String nome = request.getParameter("nome");
        String desc = request.getParameter("descricao");
        double preco = Double.parseDouble(request.getParameter("preco"));

        String sqlUpd = "UPDATE PRODUTO SET nome=?, descricao=?, preco=? WHERE id_produto=?";
        PreparedStatement statementUpdate = conn.prepareStatement(sqlUpd);
        statementUpdate.setString(1, nome);
        statementUpdate.setString(2, desc);
        statementUpdate.setDouble(3, preco);
        statementUpdate.setInt(4, Integer.parseInt(idProd));
        statementUpdate.executeUpdate();

        response.sendRedirect("pagina_admin.jsp?secao=produtos&msg=editado");
    }

    // procuras os dados do produto para preencher o formulario
    String sql = "SELECT * FROM PRODUTO WHERE id_produto=?";
    PreparedStatement statement = conn.prepareStatement(sql);
    statement.setInt(1, Integer.parseInt(idProd));
    ResultSet result = statement.executeQuery();
    if (result.next()) {
%>

<div class="container mt-2 mb-5">
    <div class="row justify-content-center">
        <div class="col-11 col-sm-10 col-md-8 col-lg-6">

            <div class="text-center mb-4">
                <h2 class="fw-bold">Editar Produto</h2>
            </div>

            <form method="POST" class="border p-4 rounded bg-white shadow-sm">

                <div class="mb-3">
                    <label class="form-label small fw-bold">Nome do Produto:</label>
                    <input type="text" name="nome" class="form-control form-control-lg"
                           value="<%= result.getString("nome") %>" required>
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-bold">Descrição:</label>
                    <textarea name="descricao" class="form-control form-control-lg" rows="3" required><%= result.getString("descricao") %></textarea>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-bold">Preço de Venda (€):</label>
                    <input type="number" name="preco" step="0.01" class="form-control form-control-lg"
                           value="<%= result.getDouble("preco") %>" required>
                </div>

                <button type="submit" class="btn btn-primary w-100 btn-lg shadow-sm">
                    Salvar Alterações
                </button>

                <div class="text-center mt-4">
                    <a href="pagina_admin.jsp?secao=produtos" class="text-decoration-none small text-primary">
                        Voltar
                    </a>
                </div>
            </form>

        </div>
    </div>
</div>

<% } %>