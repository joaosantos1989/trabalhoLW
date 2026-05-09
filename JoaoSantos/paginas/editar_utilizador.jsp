<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // id recebido ao clicar em editar utilizador
    String idUser = request.getParameter("id");

    // procuramos os dados atuais à BD para os campos não aparecerem vazios
    String sqlUser = "SELECT * FROM UTILIZADOR WHERE id_utilizador = ?";
    PreparedStatement statementUser = conn.prepareStatement(sqlUser);
    statementUser.setInt(1, Integer.parseInt(idUser));
    ResultSet resultUser = statementUser.executeQuery();

    if (resultUser.next()) { // Se o utilizador existir...
        // guardamos o tipo atual para usar caso o formulário não envie um novo
        int tipoAtual = resultUser.getInt("tipoContaId");
%>

<%-- logica do formulario --%>
<%-- recebe os dados do formulario e faz update na bd --%>
<%
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String formUser = request.getParameter("username");
        String formMail = request.getParameter("email");
        String formPass = request.getParameter("password");
        String formTipoConta = request.getParameter("tipoContaID");

        //se não for admin a editar os dados nao vai mudar o tipo de conta
        if (formTipoConta == null) {
            formTipoConta = String.valueOf(tipoAtual); //tipo de utilizador a mudar os dados pessoais
        }

        String sqlUpd;
        if (formPass.isEmpty()) {
            sqlUpd = "UPDATE UTILIZADOR SET username=?, email=?, tipoContaId=? WHERE id_utilizador=?"; // Se a password vier vazia, não a alteramos
        } else {
            sqlUpd = "UPDATE UTILIZADOR SET username=?, email=?, tipoContaId=?, password=MD5(?) WHERE id_utilizador=?";
        }

        PreparedStatement statementUpdate = conn.prepareStatement(sqlUpd);
        statementUpdate.setString(1, formUser);
        statementUpdate.setString(2, formMail);
        statementUpdate.setInt(3, Integer.parseInt(formTipoConta));

        if (formPass.isEmpty()) { // Se a password vier vazia, não a alteramos
            statementUpdate.setInt(4, Integer.parseInt(idUser));
        } else {
            statementUpdate.setString(4, formPass);
            statementUpdate.setInt(5, Integer.parseInt(idUser));
        }

        statementUpdate.executeUpdate();

        out.println("<div class='alert alert-success text-center mt-3'>✅ Dados atualizados com sucesso!</div>");
    }
%>

<%-- formulario interface --%>
<div class="container mt-2 mb-5">
    <div class="row justify-content-center">
        <div class="col-11 col-sm-10 col-md-10 col-lg-10">

            <div class="text-center mb-4">
                <h2 class="fw-bold">Editar Dados</h2>
            </div>

            <form method="POST" class="border p-4 rounded bg-white shadow-sm">

                <div class="mb-3">
                    <label class="form-label small fw-bold">O seu nome de Utilizador:</label>
                    <input type="text" name="username" class="form-control form-control-lg"
                           value="<%= resultUser.getString("username") %>" required>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-bold">O seu email:</label>
                    <input type="email" name="email" class="form-control form-control-lg"
                           value="<%= resultUser.getString("email") %>" required>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-bold">Nova Password:</label>
                    <input type="password" name="password" class="form-control form-control-lg" placeholder="deixe vazio se não quiser mudar">
                </div>
                <%-- so mostra o menu para mudar de tipo de user se for admin --%>
                <% if (session.getAttribute("TipoConta").toString().equals("1")) { %>
                <div class="mb-4">
                    <label class="form-label fw-bold small">Tipo de Conta</label>
                    <select name="tipoContaID" class="form-select" required>
                        <option value="1" <%= resultUser.getInt("tipoContaId") == 1 ? "selected" : "" %>>Administrador</option>
                        <option value="2" <%= resultUser.getInt("tipoContaId") == 2 ? "selected" : "" %>>Funcionário</option>
                        <option value="3" <%= resultUser.getInt("tipoContaId") == 3 ? "selected" : "" %>>Cliente</option>
                    </select>
                </div>
                <% } %>

                <button type="submit" class="btn btn-success w-100 btn-lg shadow-sm">
                    Salvar Alterações
                </button>

            </form>
        </div>
    </div>
</div>

<%
    }
%>