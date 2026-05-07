<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 1. Identificar qual ID editar (do link ou da sessão)
    String idParaEditar = request.getParameter("id");
    if (idParaEditar == null) {
        idParaEditar = session.getAttribute("id_utilizador").toString();
    }

    // 2. Lógica para Gravar os dados
    if (request.getParameter("gravar") != null) {
        String novoNome = request.getParameter("nome");
        String novoEmail = request.getParameter("email");
        String novaPass = request.getParameter("password");
        String novoTipo = request.getParameter("tipoContaId");

        // Atualização básica (Nome e Email)
        String sql1 = "UPDATE UTILIZADOR SET username = ?, email = ? WHERE id_utilizador = ?";
        PreparedStatement ps1 = conn.prepareStatement(sql1);
        ps1.setString(1, novoNome);
        ps1.setString(2, novoEmail);
        ps1.setInt(3, Integer.parseInt(idParaEditar));
        ps1.executeUpdate();

        // Se escreveu password, atualiza para MD5
        if (novaPass != null && !novaPass.isEmpty()) {
            String sql2 = "UPDATE UTILIZADOR SET password = MD5(?) WHERE id_utilizador = ?";
            PreparedStatement ps2 = conn.prepareStatement(sql2);
            ps2.setString(1, novaPass);
            ps2.setInt(2, Integer.parseInt(idParaEditar));
            ps2.executeUpdate();
        }

        // Se for o Admin a editar, atualiza também o Tipo de Conta
        if (session.getAttribute("tipoContaId").equals(1) && novoTipo != null) {
            String sql3 = "UPDATE UTILIZADOR SET tipoContaId = ? WHERE id_utilizador = ?";
            PreparedStatement ps3 = conn.prepareStatement(sql3);
            ps3.setInt(1, Integer.parseInt(novoTipo));
            ps3.setInt(2, Integer.parseInt(idParaEditar));
            ps3.executeUpdate();
        }

        out.println("<div class='alert alert-success'>Dados atualizados!</div>");
    }

    // 3. Buscar dados atuais para preencher as caixas
    String sqlLoad = "SELECT * FROM UTILIZADOR WHERE id_utilizador = ?";
    PreparedStatement psLoad = conn.prepareStatement(sqlLoad);
    psLoad.setInt(1, Integer.parseInt(idParaEditar));
    ResultSet rs = psLoad.executeQuery();

    if (rs.next()) {
%>

<div class="card p-4">
    <form method="POST">
        <div class="mb-3">
            <label>Nome de Utilizador:</label>
            <input type="text" name="nome" class="form-control" value="<%= rs.getString("username") %>" required>
        </div>

        <div class="mb-3">
            <label>E-mail:</label>
            <input type="email" name="email" class="form-control" value="<%= rs.getString("email") %>" required>
        </div>

        <div class="mb-3">
            <label>Password:</label>
            <input type="password" name="password" class="form-control">
        </div>

        <%-- Mostra a lista de tipos apenas se quem estiver logado for Admin --%>
        <% if (session.getAttribute("TipoConta").equals(1)) { %>
        <div class="mb-3">
            <label>Tipo de Conta:</label>
            <select name="tipoContaId" class="form-select">
                <option value="1" <%= rs.getInt("tipoContaId") == 1 ? "selected" : "" %>>Administrador</option>
                <option value="2" <%= rs.getInt("tipoContaId") == 2 ? "selected" : "" %>>Funcionário</option>
                <option value="3" <%= rs.getInt("tipoContaId") == 3 ? "selected" : "" %>>Cliente</option>
            </select>
        </div>
        <% } %>

        <button type="submit" name="gravar" class="btn btn-primary">Gravar Alterações</button>
    </form>
</div>

<%
    }
    rs.close();
    psLoad.close();
%>