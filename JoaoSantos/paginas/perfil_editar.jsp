<%-- perfil_editar.jsp --%>
<%@ page pageEncoding="UTF-8"%>

<%
    // Importante: NÃO declaramos "String userId" aqui.
    // Usamos a variável que já foi criada no ficheiro pai.

    // 1. Lógica de Gravação (POST)
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String editUsername = request.getParameter("editUsername");
        String editEmail = request.getParameter("editEmail");
        String editPass = request.getParameter("editPassword");

        // Verificamos se o userId existe (seja do URL ou da Sessão)
        if (userId == null || userId.isEmpty() || userId.equals("null")) {
            userId = String.valueOf(session.getAttribute("idUtilizador"));
        }

        if (userId != null && conn != null) {
            try {
                String sqlUpdate;
                PreparedStatement psUpdate;

                if (editPass != null && !editPass.isEmpty()) {
                    sqlUpdate = "UPDATE UTILIZADOR SET username=?, email=?, password=MD5(?) WHERE id_utilizador=?";
                    psUpdate = conn.prepareStatement(sqlUpdate);
                    psUpdate.setString(1, editUsername);
                    psUpdate.setString(2, editEmail);
                    psUpdate.setString(3, editPass);
                    psUpdate.setInt(4, Integer.parseInt(userId));
                } else {
                    sqlUpdate = "UPDATE UTILIZADOR SET username=?, email=? WHERE id_utilizador=?";
                    psUpdate = conn.prepareStatement(sqlUpdate);
                    psUpdate.setString(1, editUsername);
                    psUpdate.setString(2, editEmail);
                    psUpdate.setInt(3, Integer.parseInt(userId));
                }

                psUpdate.executeUpdate();
                out.println("<div class='alert alert-success shadow-sm'>✔️ Dados atualizados com sucesso!</div>");
            } catch (Exception e) {
                out.println("<div class='alert alert-danger shadow-sm'>❌ Erro ao atualizar: " + e.getMessage() + "</div>");
            }
        }
    }

    // 2. Lógica de Leitura (Buscar dados para o formulário)
    // Se o userId for nulo (caso do funcionário a editar-se a si próprio), usamos o da sessão
    if (userId == null || userId.isEmpty() || userId.equals("null")) {
        userId = String.valueOf(session.getAttribute("idUtilizador"));
    }

    if (userId != null && conn != null) {
        String sqlBusca = "SELECT * FROM UTILIZADOR WHERE id_utilizador = ?";
        PreparedStatement psBusca = conn.prepareStatement(sqlBusca);
        psBusca.setInt(1, Integer.parseInt(userId));
        ResultSet rsEdit = psBusca.executeQuery();

        if (rsEdit.next()) {
%>

<div class="card mt-3 shadow-sm border-primary">
    <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
        <h5 class="mb-0">👤 Editar Perfil: <%= rsEdit.getString("username") %></h5>
        <span class="badge bg-light text-primary">ID: #<%= userId %></span>
    </div>
    <div class="card-body bg-light">
        <form method="post">
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label fw-bold">Nome de Utilizador</label>
                    <input type="text" name="editUsername" class="form-control"
                           value="<%= rsEdit.getString("username") %>" required>
                </div>

                <div class="col-md-6 mb-3">
                    <label class="form-label fw-bold">E-mail</label>
                    <input type="email" name="editEmail" class="form-control"
                           value="<%= rsEdit.getString("email") %>" required>
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-bold">Nova Password</label>
                <input type="password" name="editPassword" class="form-control"
                       placeholder="Deixe em branco para manter a atual">
                <div class="form-text">A password será encriptada automaticamente.</div>
            </div>

            <div class="d-grid mt-4">
                <button type="submit" class="btn btn-primary btn-lg shadow-sm">
                    💾 Gravar Alterações
                </button>
            </div>
        </form>
    </div>
</div>

<%
        }
    }
%>