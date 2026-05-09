<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String nome = request.getParameter("nome");
        double preco = Double.parseDouble(request.getParameter("preco")); // Aceita 2.75

        String sql = "INSERT INTO PRODUTO (nome, preco) VALUES (?, ?)";
        PreparedStatement st = conn.prepareStatement(sql);
        st.setString(1, nome);
        st.setDouble(2, preco);
        st.executeUpdate();

        response.sendRedirect("pagina_admin.jsp?secao=produtos&msg=adicionado");
    }
%>

<div class="card shadow-sm border-0 mt-3">
    <div class="card-header bg-success text-white fw-bold">📦 Adicionar Novo Produto</div>
    <div class="card-body p-4">
        <form method="POST">
            <div class="mb-3">
                <label class="form-label fw-bold">Nome do Produto</label>
                <input type="text" name="nome" class="form-control" required>
            </div>
            <div class="mb-4">
                <label class="form-label fw-bold">Preço (€)</label>
                <input type="number" name="preco" step="0.01" class="form-control" placeholder="2.75" required>
            </div>
            <button type="submit" class="btn btn-success w-100">Gravar Produto</button>
            <a href="pagina_admin.jsp?secao=produtos" class="btn btn-light w-100 mt-2 border">Cancelar</a>
        </form>
    </div>
</div>