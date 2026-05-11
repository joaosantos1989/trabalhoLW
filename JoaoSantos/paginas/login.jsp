<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<% if ("n".equals(request.getParameter("needLogin"))) { %>
<div class="container mt-2">
    <div class="alert alert-danger alert-dismissible fade show text-center" role="alert">
         Precisa de estar logado primeiro para adicionar produtos ao carrinho!
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<!-- tipo de utilizador errado -->
<% if ("acesso_negado".equals(request.getParameter("needLogin"))) { %>
<div class="container mt-2">
    <div class="alert alert-danger alert-dismissible fade show text-center" role="alert">
        Acesso negado!
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</div>
<% } %>

<div class="container mt-5 mb-5">
    <div class="row justify-content-center">
        <div class="col-11 col-sm-8 col-md-6 col-lg-4">

            <div class="text-center mb-4">
                <h2 class="fw-bold">Login</h2>
            </div>

            <!-- Formulário-->
            <form action="login_valida.jsp" method="POST" class="border p-4 rounded bg-white shadow-sm">

                <div class="mb-3">
                    <label class="form-label small fw-bold">Utilizador</label>
                    <input type="text" name="username" class="form-control form-control-lg" placeholder="" required>
                </div>

                <div class="mb-4">
                    <label class="form-label small fw-bold">Password</label>
                    <input type="password" name="password" class="form-control form-control-lg" placeholder="" required>
                </div>

                <button type="submit" class="btn btn-success w-100 btn-lg shadow-sm">
                    Entrar
                </button>

                <div class="text-center mt-4">
                    <a href="registo.jsp" class="text-decoration-none small text-success">Registar</a>
                </div>
            </form>

        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>