*** Settings ***
Documentation    Cadastro de novo usuario e validacao na listagem - Serve Rest Front
Resource         ../resource/server-rest-front.resource
Test Teardown    Run Keyword And Ignore Error    Close Browser
Suite Teardown    Close Browser    ALL


*** Test Cases ***
Cenario 01 - Cadastrar novo usuario e conferir na listagem
    [Documentation]    Cadastrar novo usuario com dados dinamicos e validar se aparece na lista de usuarios
    [Tags]             cadastro    listagem    smoke    playwright
    Abrir o navegador
    Ir para o site Serve Rest Front
    Preencher os dados do novo usuario e cadastrar
    Conferir usuario cadastrado com sucesso
    Acessar a Lista de usuarios
    Conferir que o usuario aparece na listagem    ${EMAIL}
