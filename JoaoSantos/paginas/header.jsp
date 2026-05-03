<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8" />
    <title>FelixUberShop - Home</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" />
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
                    // se não estiver logado
                        if (session.getAttribute("autenticado") == null) {
                    %>
                    <li class="nav-item"><a class="nav-link" href="login.jsp">Login</a></li>
                    <%
                        } else { //se estiver logado
                    %>
                        <li class="nav-item"><a class="nav-link" href="logout.jsp">Logout</a></li>
                    <%
                        }
                    %>
            </ul>
            <form class="d-flex">
                <button class="btn btn-outline-success" type="button">
                    <i class="bi-cart-fill me-1"></i> Carro
                    <span class="badge bg-success text-white ms-1 rounded-pill">0</span>
                </button>
            </form>
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