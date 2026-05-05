<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="header.jsp" %>

<div class="container py-5 mt-5">
    <div class="row justify-content-center">
        <div class="col-md-8 text-center">

            <%
                // 1. Verificar Login
                if (session.getAttribute("autenticado") == null) {
            %>
            <div class="alert alert-warning">
                Precisa de ter conta para comprar. <br>
                <a href="login.jsp" class="btn btn-primary mt-2">Fazer Login</a>
                <a href="registo.jsp" class="btn btn-primary mt-2">Registar</a>
            </div>
            <%
                    return; // Pára aqui
                }

                // 2. Buscar o nome do utilizador da sessão (que criaste no login_valida.jsp)
                String nomeUser = (String) session.getAttribute("utilizador");
                String userId = request.getParameter("id");

                if (userId != null && conn != null) {
                    try {
                        int idProduto = Integer.parseInt(userId);

                        // --- PASSO 1: Buscar Saldo do Cliente e ID da Carteira ---
                        // Usamos um JOIN simples
                        String sql = "SELECT u.id_utilizador, c.id_carteira, c.saldo FROM UTILIZADOR u, CARTEIRA c " +
                                "WHERE u.id_utilizador = c.id_utilizador AND u.username = ?";
                        PreparedStatement statement = conn.prepareStatement(sql);
                        statement.setString(1, nomeUser);
                        ResultSet result = statement.executeQuery();

                        if (result.next()) {
                            int idCliente = result.getInt("id_utilizador");
                            int idCarteira= result.getInt("id_carteira");
                            double saldo = result.getDouble("saldo");

                            // --- PASSO 2: Buscar Dados do Produto ---
                            PreparedStatement statement2 = conn.prepareStatement("SELECT nome, preco FROM PRODUTO WHERE id_produto = ?");
                            statement2.setInt(1, idProduto);
                            ResultSet result2 = statement2.executeQuery();

                            if (result2.next()) {
                                String nomeProduto = result2.getString("nome");
                                double precoProduto = result2.getDouble("preco");

                                // --- PASSO 3: Verificar se há dinheiro ---
                                if (saldo >= precoProduto) {

                                    // A. Retirar dinheiro ao cliente
                                    PreparedStatement statement3 = conn.prepareStatement("UPDATE CARTEIRA SET saldo = saldo - ? WHERE id_carteira = ?");
                                    statement3.setDouble(1, precoProduto);
                                    statement3.setInt(2, idCarteira);
                                    statement3.executeUpdate();

                                    // B. Dar dinheiro à loja
                                    // Primeiro descobrimos a carteira da loja
                                    Statement statement4 = conn.createStatement();
                                    ResultSet result3 = statement4.executeQuery("SELECT id_carteira FROM UTILIZADOR u, CARTEIRA c WHERE u.id_utilizador = c.id_utilizador AND c.tipoCarteiraId = 2");
                                    int idCartLoja = 0;
                                    if(result3.next()) idCartLoja = result3.getInt("id_carteira");

                                    PreparedStatement statement5 = conn.prepareStatement("UPDATE CARTEIRA SET saldo = saldo + ? WHERE id_carteira = ?");
                                    statement5.setDouble(1, precoProduto);
                                    statement5.setInt(2, idCartLoja);
                                    statement5.executeUpdate();

                                    // C. Criar a Encomenda (Estado 1 = Pendente)
                                    PreparedStatement statement6 = conn.prepareStatement("INSERT INTO ENCOMENDA (id_utilizador, data_hora, valor_total, estado) VALUES (?, NOW(), ?, 1)");
                                    statement6.setInt(1, idCliente);
                                    statement6.setDouble(2, precoProduto);
                                    statement6.executeUpdate();

                                    // Sucesso!
                                    out.println("<h2 class='text-success'>Compra realizada!</h2>");
                                    out.println("<p>Comprou <b>" + nomeProduto + "</b> por " + precoProduto + "€</p>");
                                    out.println("<a href='pagina_principal.jsp' class='btn btn-success'>Voltar</a>");

                                } else {
                                    out.println("<div class='alert alert-danger'>Não tem saldo suficiente!</div>");
                                    out.println("<a href='pagina_principal.jsp' class='btn btn-secondary'>Voltar</a>");
                                }
                            }
                        }
                    } catch (Exception e) {
                        out.println("Erro na compra: " + e.getMessage());
                    }
                }
            %>

        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>