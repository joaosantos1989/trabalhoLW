<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // 1. Pegar dados da sessão (Nomes iguais ao teu login.jsp)
    Object sessaoID = session.getAttribute("idUtilizador");
    Object sessaoTipo = session.getAttribute("TipoConta");

    // Só avança se estiver logado
    if (sessaoID != null && sessaoTipo != null) {
        int idLogado = (int) sessaoID;
        int tipoUser = (int) sessaoTipo;

        // ID de quem vamos mexer (se não houver no link, usa o próprio)
        String idAlvoParam = request.getParameter("id");
        String idAlvo = (idAlvoParam != null && !idAlvoParam.isEmpty()) ? idAlvoParam : String.valueOf(idLogado);

        // Definir link de retorno
        String linkVoltar = (tipoUser == 1) ? "pagina_admin.jsp?secao=carteira" : "pagina_cliente.jsp?secao=carteira";

        // 2. Lógica de Gravação (POST)
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            double v = Double.parseDouble(request.getParameter("valor"));
            String op = request.getParameter("operacao");
            double vFinal = ("retirar".equals(op)) ? -v : v;

            // Update Saldo
            PreparedStatement ps1 = conn.prepareStatement("UPDATE carteira SET saldo = saldo + ? WHERE id_utilizador = ?");
            ps1.setDouble(1, vFinal);
            ps1.setInt(2, Integer.parseInt(idAlvo));
            ps1.executeUpdate();

            // Log de Movimento
            PreparedStatement ps2 = conn.prepareStatement("INSERT INTO movimento_carteira (data_hora, valor, tipoOperacaoId, id_carteira_origem, id_carteira_destino) VALUES (NOW(), ?, ?, ?, ?)");
            ps2.setDouble(1, v);
            ps2.setInt(2, ("adicionar".equals(op) ? 2 : 3));
            ps2.setInt(3, idLogado);
            ps2.setInt(4, Integer.parseInt(idAlvo));
            ps2.executeUpdate();

            response.sendRedirect(linkVoltar + "&msg=saldo_ok");
            return;
        }

        // 3. Buscar Nome e Saldo Atual para mostrar
        PreparedStatement ps3 = conn.prepareStatement("SELECT u.username, c.saldo FROM utilizador u, carteira c WHERE u.id_utilizador = c.id_utilizador AND u.id_utilizador = ?");
        ps3.setInt(1, Integer.parseInt(idAlvo));
        ResultSet rs3 = ps3.executeQuery();

        if (rs3.next()) {
%>

<div class="row justify-content-center mt-3">
    <div class="col-md-5">
        <div class="card p-4 shadow-sm border-0">
            <h4 class="text-center">Gerir: <strong><%= rs3.getString("username") %></strong></h4>

            <div class="alert alert-info text-center my-3">
                Saldo Atual: <strong><%= rs3.getDouble("saldo") %>€</strong>
            </div>

            <form method="POST">
                <div class="mb-3">
                    <label class="form-label small fw-bold">Valor (€):</label>
                    <input type="number" name="valor" step="0.01" class="form-control" required placeholder="0.00">
                </div>

                <div class="mb-3">
                    <label class="form-label small fw-bold">Operação:</label>
                    <select name="operacao" class="form-select">
                        <option value="adicionar">➕ Adicionar Saldo</option>
                        <option value="retirar">➖ Retirar Saldo</option>
                    </select>
                </div>

                <button type="submit" class="btn btn-primary w-100">Confirmar Alteração</button>
                <a href="<%= linkVoltar %>" class="btn btn-outline-secondary w-100 mt-2">← Voltar</a>
            </form>
        </div>
    </div>
</div>

<%
        } // Fecha if(rs3.next)
    } // Fecha if(sessaoID != null)
%>