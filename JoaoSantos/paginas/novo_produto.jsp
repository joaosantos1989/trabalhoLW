<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- segurança de login ---
    if (autenticado == null || tipoConta == null || (int) tipoConta != 1) {
        // expulsa para o login
        response.sendRedirect("login.jsp?needLogin=acesso_negado");
        return; // Interrompe a página
    }
%>

<% // adiciona à bd o novo produto
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String nome = request.getParameter("nome");
        String desc = request.getParameter("descricao");
        double preco = Double.parseDouble(request.getParameter("preco"));

        String sql = "INSERT INTO PRODUTO (nome, descricao, preco) VALUES (?, ?, ?)";
        PreparedStatement st = conn.prepareStatement(sql);
        st.setString(1, nome);
        st.setString(2, desc);
        st.setDouble(3, preco);
        st.executeUpdate();

        response.sendRedirect("pagina_admin.jsp?secao=produtos&msg=adicionado");
    }
%>
<!-- formulario -->
<div class="container mt-2 mb-5">
    <div class="row justify-content-center">
        <div class="col-11 col-sm-10 col-md-8 col-lg-6">

            <div class="text-center mb-4">
                <h2 class="fw-bold">Novo Produto</h2>
            </div>

            <form method="POST" class="border p-4 rounded bg-white shadow-sm">

                <div class="mb-3">
                    <label class="form-label small fw-bold">Nome do Produto:</label>
                    <input type="text" name="nome" class="form-control form-control-lg" required>
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-bold">Descrição:</label>
                    <textarea name="descricao" class="form-control form-control-lg" rows="3" required></textarea>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-bold">Preço (€):</label>
                    <input type="number" name="preco" step="0.01" class="form-control form-control-lg" placeholder="0.00" required>
                </div>

                <button type="submit" class="btn btn-success w-100 btn-lg shadow-sm">
                    Guardar Produto
                </button>

                <div class="text-center mt-4">
                    <a href="pagina_admin.jsp?secao=produtos" class="text-decoration-none small text-success">Voltar</a>
                </div>
            </form>
        </div>
    </div>
</div>