<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<%
    // Lógica para o contador do carrinho
    int totalItens = 0;
    if (session.getAttribute("autenticado") != null) {
        String userLogado = (String) session.getAttribute("utilizador");
        try {
            if (conn != null) {
                // Query para somar a quantidade de itens no carrinho (estado 0)
                String sql = "SELECT SUM(i.quantidade) FROM ITEM_ENCOMENDA i " +
                        "JOIN ENCOMENDA e ON i.id_encomenda = e.id_encomenda " +
                        "JOIN UTILIZADOR u ON e.id_utilizador = u.id_utilizador " +
                        "WHERE u.username = ? AND e.estado = 0";
                PreparedStatement statement = conn.prepareStatement(sql);
                statement.setString(1, userLogado);
                ResultSet result = statement.executeQuery();

                if (result.next()) {
                    totalItens = result.getInt(1);
                }
                result.close();
                statement.close();
            }
        } catch (Exception e) {
            // Em caso de erro, o contador permanece a 0
        }
    }
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8" />
    <title>FelixUberShop - Home</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        .bg-verde-shop { background-color: #198754; }
        .card-img-top { object-fit: cover; height: 200px; background-color: #f8f9fa; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-light border-bottom">
    <div class="container px-4">
        <a class="navbar-brand fw-bold text-success" href="pagina_principal.jsp">FelixUberShop</a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav me-auto">
                <%
                    //verifica se o utilizador não está logado
                    if (session.getAttribute("autenticado") == null) {
                %>
                <li class="nav-item"><a class="nav-link" href="login.jsp">Login</a></li>
                <li class="nav-item"><a class="nav-link" href="registo.jsp">Registar</a></li>
                <%
                } else {
                    // se estiver logado, vamos buscar o tipo
                    int tipo = (int) session.getAttribute("TipoConta");//convertemos para int porque para o Java ainda é um objeto
                %>
                <li class="nav-item"><a class="nav-link " href="logout.jsp">Sair</a></li>

                <%
                    //paginas principais de cada tipo de utilizador
                    if (tipo == 1) { // ADMINISTRADOR
                %>
                <li class="nav-item">
                    <a class="nav-link fw-bold text-primary" href="pagina_admin.jsp">Painel Admin</a>
                </li>
                <%
                } else if (tipo == 2) { // FUNCIONÁRIO
                %>
                <li class="nav-item">
                    <a class="nav-link fw-bold text-primary" href="pagina_funcionario.jsp">Painel Funcionario</a>
                </li>
                <%
                } else { // CLIENTE
                %>
                <li class="nav-item">
                    <a class="nav-link fw-bold text-primary" href="pagina_cliente.jsp">Painel Cliente</a>
                </li>
                <%
                        }
                    }
                %>
            </ul>
        </div>
        <!-- Carinho de compras -->

        <div class="d-flex">
            <a href="carrinho.jsp" class="btn btn-outline-success">
                <i class="bi-cart-fill me-1"></i>
                Carrinho
                <span class="badge bg-success text-white ms-1 rounded-pill"><%= totalItens %></span>
            </a>
        </div>
    </div>
</nav>

<header class="bg-verde-shop py-5">
    <div class="container px-4 my-5">
        <div class="text-center text-white">
            <h1 class="display-4 fw-bolder">FelixUberShop</h1>
            <p class="lead fw-normal text-white-50 mb-0">FelixUberShop</p>
        </div>
    </div>
</header>