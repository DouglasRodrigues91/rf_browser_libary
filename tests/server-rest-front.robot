*** Settings ***
Resource    ../resource/server-rest-front.resource
Test Teardown    Finalizar Evidencias
Suite Setup    Cadastrar Usuario e Logar

*** Test Cases ***
Login com sucesso Serve Rest Front
    [Tags]    cadastro
    Given Abrir o navegador
    And Ir para o site Serve Rest Front
    When Preencher os dados do novo usuario e cadastrar
    Then Conferir usuario cadastrado com sucesso
    Conferir usuario cadastrado com sucesso
    

Cenario 02 - Exemplo Utilizando Requisicao HTTP
    Abrir o navegador
    Ir para o site Serve Rest Front
    Criar usuario via API
    Logar com o usuario cadastrado via API


Exemplo Utilizando o Storage Armazenado no Contexto
    Cadastrar Usuario e Logar
    Abrir o Site Serve Rest Front Logado