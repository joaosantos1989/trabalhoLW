<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<div class="container mt-4">
    <div class="d-flex flex-wrap gap-2 justify-content-center mb-4">
        <a href="pagina_funcionario.jsp?secao=encomendas" class="btn btn-primary shadow-sm">📋 Encomendas</a>
        <a href="pagina_funcionario.jsp?secao=saldo" class="btn btn-primary shadow-sm">💰 Saldo de Clientes</a>
        <a href="pagina_funcionario.jsp?secao=pessoal" class="btn btn-primary shadow-sm">👤 Dados Pessoais</a>
    </div>

    <div id="secao-dashboard">
        <%
            String secao = request.getParameter("secao");

            // SEÇÃO: SALDO DE CLIENTES
            if ("saldo".equals(secao)) {
        %>
        <h2 class="text-primary border-bottom pb-2 mb-4">💰 Gestão de Saldo de Clientes</h2>
        <div class="alert alert-info">Aqui poderá consultar e carregar o saldo dos clientes (Em construção).</div>
        <%
            // SEÇÃO: DADOS PESSOAIS
        } else if ("pessoal".equals(secao)) {
        %>
        <h2 class="text-primary border-bottom pb-2 mb-4">👤 Os Meus Dados Pessoais</h2>
        <div class="alert alert-info">Aqui poderá editar o seu perfil de funcionário (Em construção).</div>
        <%
            // SEÇÃO POR DEFEITO: ENCOMENDAS
        } else {
        %>
        <h2 class="text-primary border-bottom pb-2 mb-4">📋 Encomendas Pendentes de Validação</h2>

        <div class="table-hover border">
            <table class="table table-hover shadow-sm bg-white">
                <thead class="table-dark">
                <tr>
                    <th>ID Único</th>
                    <th>Cliente</th>
                    <th>Data/Hora</th>
                    <th>Valor Total</th>
                    <th class="text-center">Ações</th>
                </tr>
                </thead>
                <tbody>
                <%
                    try {
                        if (conn != null) {
                            // Estado 1 = Aguarda validação do funcionário
                            String sql = "SELECT e.id_encomenda, u.username, e.data_hora, e.valor_total " +
                                    "FROM ENCOMENDA e, UTILIZADOR u " +
                                    "WHERE e.id_utilizador = u.id_utilizador AND e.estado = 1 " +
                                    "ORDER BY e.data_hora DESC";

                            Statement statement = conn.createStatement();
                            ResultSet result = statement.executeQuery(sql);

                            boolean temEncomendas = false;
                            while(result.next()) {
                                temEncomendas = true;
                %>
                <tr>
                    <td><span class="badge bg-secondary">#<%= result.getInt("id_encomenda") %></span></td>
                    <td><%= result.getString("username") %></td>
                    <td><%= result.getTimestamp("data_hora") %></td>
                    <td class="fw-bold text-success"><%= result.getDouble("valor_total") %>€</td>
                    <td class="text-center">
                        <%-- Botão para a página de ação que criámos antes --%>
                        <a href="validar_encomenda.jsp?id_enc=<%= result.getInt("id_encomenda") %>"
                           class="btn btn-sm btn-success shadow-sm">Validar</a>

                        <a href="cancelar_encomenda.jsp?id_enc=<%= result.getInt("id_encomenda") %>"
                           class="btn btn-sm btn-outline-danger">Cancelar</a>
                    </td>
                </tr>
                <%
                            }
                            if (!temEncomendas) {
                                out.println("<tr><td colspan='5' class='text-center text-muted p-4'>Não existem encomendas pendentes.</td></tr>");
                            }
                            result.close();
                            statement.close();
                        }
                    } catch (Exception e) {
                        out.println("<tr><td colspan='5' class='text-danger'>Erro: " + e.getMessage() + "</td></tr>");
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
            } // Fim do else (encomendas)
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>