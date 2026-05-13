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
    // nome do utilizador na barra de pesquisa
    String pesquisa = request.getParameter("txtPesquisa");
%>

<div class="container mt-3">
    <h2 class="border-bottom pb-2">📜 Registos de Movimentos</h2>

    <%-- formulario --%>
    <form action="pagina_admin.jsp" method="GET" class="mb-4 mt-3">
        <input type="hidden" name="secao" value="registos">
        <input type="text" name="txtPesquisa" class="form-control d-inline-block w-50"
               placeholder="Pesquisar por nome do utilizador..."
               value="<%= (pesquisa != null) ? pesquisa : "" %>">  <%-- se for null mostra todos os movimentos, se não mostra os movimentos do utilizador --%>
        <button type="submit" class="btn btn-primary">Pesquisar</button>
    </form>

    <table class="table table-bordered">
        <thead class="table-secondary">
        <tr>
            <th>ID</th>
            <th>Data</th>
            <th>Valor</th>
            <th>Origem (De)</th>
            <th>Destino (Para)</th>
            <th>Tipo Movimento</th>
        </tr>
        </thead>
        <tbody>
        <%
            if (conn != null) {
                // procuramos nos nomes dos utilizadores de cada movimento
                String sql = "SELECT m.*, u1.username AS nome1, u2.username AS nome2 " +
                        "FROM movimento_carteira m, utilizador u1, utilizador u2 " +
                        "WHERE m.id_carteira_origem = u1.id_utilizador " +
                        "AND m.id_carteira_destino = u2.id_utilizador";

                // se houver pesquisa, filtramos pelos nomes
                if (pesquisa != null && !pesquisa.isEmpty()) {
                    sql += " AND (u1.username LIKE '%" + pesquisa + "%' OR u2.username LIKE '%" + pesquisa + "%')";
                }

                // Ordenar pelos mais recentes
                sql += " ORDER BY m.id_movimento DESC";

                Statement statementOrder = conn.createStatement();
                ResultSet resultOrder = statementOrder.executeQuery(sql);

                while(resultOrder.next()) {
                    int tipoOperacao = resultOrder.getInt("tipoOperacaoId");// tipoConta de operacao
                    String nomeOperacao = "";
                    // damos o nome da operacao
                    if (tipoOperacao == 1) { nomeOperacao = "Saldo Adicionado"; }
                    else if (tipoOperacao == 2) { nomeOperacao = "Saldo Retirado"; }
                    else if (tipoOperacao == 3) { nomeOperacao = "Encomenda Paga"; }
        %>
        <tr>
            <td>#<%= resultOrder.getInt("id_movimento") %></td>
            <td><%= resultOrder.getString("data_hora") %></td>
            <td class="text-success fw-bold"><%= resultOrder.getDouble("valor") %>€</td>
            <%-- nomes dos utilizadores pesquisados --%>
            <td><%= resultOrder.getString("nome1") %></td>
            <td><%= resultOrder.getString("nome2") %></td>
            <td class="text-primary fw-bold"><%= nomeOperacao %></td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>
</div>